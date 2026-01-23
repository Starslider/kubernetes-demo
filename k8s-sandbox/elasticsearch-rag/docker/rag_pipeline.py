import os
import json
import logging
from flask import Flask, request, jsonify
from elasticsearch import Elasticsearch
from sentence_transformers import SentenceTransformer
import requests

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# Initialize Elasticsearch client
es_host = os.getenv('ELASTICSEARCH_HOST', 'elasticsearch')
es_port = os.getenv('ELASTICSEARCH_PORT', '9200')
es_index = os.getenv('ELASTICSEARCH_INDEX', 'rag-documents')
embedding_model_name = os.getenv('EMBEDDING_MODEL', 'all-MiniLM-L6-v2')

es = Elasticsearch([f'http://{es_host}:{es_port}'], request_timeout=30, max_retries=3, retry_on_timeout=True)
embedding_model = None
es_ready = False

# Initialize embedding model (pre-loaded in Docker image, but verify)
try:
    logger.info(f"Loading embedding model: {embedding_model_name}")
    embedding_model = SentenceTransformer(embedding_model_name)
    logger.info("Embedding model loaded successfully")
except Exception as e:
    logger.error(f"Failed to load embedding model: {e}")

# Ensure index exists with proper mapping
def ensure_index():
    global es_ready
    try:
        if not es.ping():
            logger.warning("Elasticsearch is not ready yet")
            es_ready = False
            return
        
        es_ready = True
        if not es.indices.exists(index=es_index):
            if embedding_model is None:
                logger.warning("Cannot create index: embedding model not loaded")
                return
                
            mapping = {
                "mappings": {
                    "properties": {
                        "text": {"type": "text"},
                        "metadata": {"type": "object"},
                        "embedding": {
                            "type": "dense_vector",
                            "dims": embedding_model.get_sentence_embedding_dimension()
                        },
                        "timestamp": {"type": "date"}
                    }
                }
            }
            es.indices.create(index=es_index, body=mapping)
            logger.info(f"Created index: {es_index}")
        else:
            logger.info(f"Index {es_index} already exists")
    except Exception as e:
        logger.warning(f"Error ensuring index exists: {e}")
        es_ready = False

# Initialize on startup (non-blocking)
import threading
def init_background():
    import time
    max_retries = 30
    retry_count = 0
    while retry_count < max_retries:
        try:
            ensure_index()
            if es_ready:
                break
        except Exception as e:
            logger.warning(f"Initialization attempt {retry_count + 1} failed: {e}")
        retry_count += 1
        time.sleep(2)

init_thread = threading.Thread(target=init_background, daemon=True)
init_thread.start()

@app.route('/health', methods=['GET'])
def health():
    try:
        # Check if Flask app is running
        app_ready = True
        
        # Check Elasticsearch connection (non-blocking)
        es_status = False
        try:
            es_status = es.ping()
        except Exception as e:
            logger.debug(f"Elasticsearch ping failed: {e}")
        
        # Check if embedding model is loaded
        model_ready = embedding_model is not None
        
        # Determine overall health
        if app_ready and es_status and model_ready:
            status = "healthy"
            http_status = 200
        elif app_ready:
            # App is running but dependencies not fully ready
            status = "starting"
            http_status = 200
        else:
            status = "unhealthy"
            http_status = 503
        
        return jsonify({
            "status": status,
            "app": "ready" if app_ready else "not ready",
            "elasticsearch": "connected" if es_status else "disconnected",
            "embedding_model": "loaded" if model_ready else "loading"
        }), http_status
    except Exception as e:
        logger.error(f"Health check error: {e}")
        return jsonify({
            "status": "error",
            "error": str(e)
        }), 503

@app.route('/api/v1/index', methods=['POST'])
def index_document():
    try:
        if not es_ready:
            return jsonify({"error": "Elasticsearch is not ready"}), 503
        if embedding_model is None:
            return jsonify({"error": "Embedding model is not loaded"}), 503
            
        data = request.json
        if not data or 'text' not in data:
            return jsonify({"error": "Missing 'text' field"}), 400
        
        text = data['text']
        metadata = data.get('metadata', {})
        
        # Generate embedding
        embedding = embedding_model.encode(text).tolist()
        
        # Index document
        doc = {
            "text": text,
            "metadata": metadata,
            "embedding": embedding,
            "timestamp": "now"
        }
        
        result = es.index(index=es_index, document=doc)
        
        return jsonify({
            "success": True,
            "id": result['_id'],
            "index": result['_index']
        }), 201
        
    except Exception as e:
        logger.error(f"Error indexing document: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/api/v1/search', methods=['POST'])
def search():
    try:
        if not es_ready:
            return jsonify({"error": "Elasticsearch is not ready"}), 503
        if embedding_model is None:
            return jsonify({"error": "Embedding model is not loaded"}), 503
            
        data = request.json
        if not data or 'query' not in data:
            return jsonify({"error": "Missing 'query' field"}), 400
        
        query_text = data['query']
        top_k = data.get('top_k', 5)
        
        # Generate query embedding
        query_embedding = embedding_model.encode(query_text).tolist()
        
        # Search using kNN
        search_body = {
            "knn": {
                "field": "embedding",
                "query_vector": query_embedding,
                "k": top_k,
                "num_candidates": top_k * 10
            },
            "_source": ["text", "metadata", "timestamp"]
        }
        
        results = es.search(index=es_index, body=search_body)
        
        hits = []
        for hit in results['hits']['hits']:
            hits.append({
                "id": hit['_id'],
                "score": hit['_score'],
                "text": hit['_source']['text'],
                "metadata": hit['_source'].get('metadata', {}),
                "timestamp": hit['_source'].get('timestamp')
            })
        
        return jsonify({
            "query": query_text,
            "results": hits,
            "total": results['hits']['total']['value']
        }), 200
        
    except Exception as e:
        logger.error(f"Error searching: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/api/v1/batch-index', methods=['POST'])
def batch_index():
    try:
        if not es_ready:
            return jsonify({"error": "Elasticsearch is not ready"}), 503
        if embedding_model is None:
            return jsonify({"error": "Embedding model is not loaded"}), 503
            
        data = request.json
        if not data or 'documents' not in data:
            return jsonify({"error": "Missing 'documents' array"}), 400
        
        documents = data['documents']
        if not isinstance(documents, list):
            return jsonify({"error": "'documents' must be an array"}), 400
        
        success_count = 0
        error_count = 0
        errors = []
        
        for doc in documents:
            try:
                if 'text' not in doc:
                    errors.append(f"Document missing 'text' field: {doc}")
                    error_count += 1
                    continue
                
                text = doc['text']
                metadata = doc.get('metadata', {})
                
                # Generate embedding
                embedding = embedding_model.encode(text).tolist()
                
                # Index document
                es_doc = {
                    "text": text,
                    "metadata": metadata,
                    "embedding": embedding,
                    "timestamp": "now"
                }
                
                es.index(index=es_index, document=es_doc)
                success_count += 1
                
            except Exception as e:
                error_count += 1
                errors.append(f"Error indexing document: {str(e)}")
        
        return jsonify({
            "success": True,
            "processed": success_count,
            "failed": error_count,
            "total": len(documents),
            "errors": errors
        }), 200
        
    except Exception as e:
        logger.error(f"Error in batch indexing: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/api/v1/stats', methods=['GET'])
def stats():
    try:
        if not es_ready:
            return jsonify({"error": "Elasticsearch is not ready"}), 503
            
        stats = es.indices.stats(index=es_index)
        count = es.count(index=es_index)
        
        return jsonify({
            "index": es_index,
            "document_count": count['count'],
            "index_size": stats['indices'][es_index]['total']['store']['size_in_bytes']
        }), 200
        
    except Exception as e:
        logger.error(f"Error getting stats: {e}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    port = int(os.getenv('PORT', 8080))
    app.run(host='0.0.0.0', port=port, debug=False)

