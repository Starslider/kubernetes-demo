# Elasticsearch RAG Pipeline

A Kubernetes deployment of Elasticsearch with a RAG (Retrieval-Augmented Generation) pipeline service for semantic search and document indexing.

## Architecture

```
┌─────────────────────┐
│  RAG Pipeline API   │
│  (Flask + Python)   │
└──────────┬──────────┘
           │
           │ Index & Search
           │
┌──────────▼──────────┐
│   Elasticsearch     │
│   (StatefulSet)     │
└─────────────────────┘
```

## Components

### Elasticsearch
- **Type**: StatefulSet (for persistent storage)
- **Image**: `docker.elastic.co/elasticsearch/elasticsearch:8.11.0`
- **Storage**: 20Gi persistent volume
- **Resources**: 1-2Gi memory, 0.5-1 CPU
- **Security**: Disabled (for development - enable in production)

### RAG Pipeline Service
- **Type**: Deployment
- **Image**: `python:3.11-slim`
- **Features**:
  - Document indexing with embeddings
  - Semantic search using vector similarity
  - Batch indexing support
  - Health checks and statistics

## Features

- **Vector Search**: Uses sentence transformers to generate embeddings
- **Semantic Search**: kNN search in Elasticsearch for similarity matching
- **Document Indexing**: Single and batch document indexing
- **Metadata Support**: Store custom metadata with documents
- **Health Monitoring**: Health endpoints for both services

## API Endpoints

### Health Check
```
GET /health
```

### Index Document
```
POST /api/v1/index
Content-Type: application/json

{
  "text": "Your document text here",
  "metadata": {
    "source": "example",
    "author": "John Doe"
  }
}
```

### Search Documents
```
POST /api/v1/search
Content-Type: application/json

{
  "query": "What is machine learning?",
  "top_k": 5
}
```

### Batch Index
```
POST /api/v1/batch-index
Content-Type: application/json

{
  "documents": [
    {
      "text": "First document",
      "metadata": {"source": "doc1"}
    },
    {
      "text": "Second document",
      "metadata": {"source": "doc2"}
    }
  ]
}
```

### Statistics
```
GET /api/v1/stats
```

## Configuration

### Environment Variables

**RAG Pipeline:**
- `ELASTICSEARCH_HOST`: Elasticsearch service hostname (default: elasticsearch)
- `ELASTICSEARCH_PORT`: Elasticsearch port (default: 9200)
- `ELASTICSEARCH_INDEX`: Index name (default: rag-documents)
- `EMBEDDING_MODEL`: Sentence transformer model (default: all-MiniLM-L6-v2)
- `PORT`: API server port (default: 8080)

### ConfigMap

Edit `configmap.yaml` to change:
- Index name
- Embedding model (must match dimensions in code)

## Deployment

### Using kubectl
```bash
kubectl apply -k k8s-sandbox/elasticsearch-rag/
```

### Using ArgoCD
The application is configured in `apps/elasticsearch-rag.yaml` and will be automatically deployed by ArgoCD.

## Verification

```bash
# Check pods
kubectl get pods -n elasticsearch-rag

# Check services
kubectl get svc -n elasticsearch-rag

# Check Elasticsearch health
kubectl port-forward -n elasticsearch-rag svc/elasticsearch 9200:9200
curl http://localhost:9200/_cluster/health

# Check RAG pipeline health
kubectl port-forward -n elasticsearch-rag svc/rag-pipeline 8080:80
curl http://localhost:8080/health
```

## Example Usage

### Index a document
```bash
curl -X POST http://localhost:8080/api/v1/index \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Elasticsearch is a distributed search and analytics engine.",
    "metadata": {
      "source": "documentation",
      "category": "technology"
    }
  }'
```

### Search documents
```bash
curl -X POST http://localhost:8080/api/v1/search \
  -H "Content-Type: application/json" \
  -d '{
    "query": "What is Elasticsearch?",
    "top_k": 3
  }'
```

### Batch index
```bash
curl -X POST http://localhost:8080/api/v1/batch-index \
  -H "Content-Type: application/json" \
  -d '{
    "documents": [
      {"text": "First document", "metadata": {"id": 1}},
      {"text": "Second document", "metadata": {"id": 2}}
    ]
  }'
```

## Production Considerations

1. **Security**: Enable Elasticsearch security (xpack.security.enabled=true)
2. **TLS**: Configure TLS for Elasticsearch communication
3. **Authentication**: Add authentication to RAG pipeline API
4. **Resource Limits**: Adjust based on workload
5. **Replication**: Increase Elasticsearch replicas for HA
6. **Backup**: Implement backup strategy for Elasticsearch data
7. **Monitoring**: Add Prometheus metrics and logging
8. **Network Policies**: Restrict network access

## Troubleshooting

### Elasticsearch not starting
- Check PVC storage class availability
- Verify resource limits
- Check logs: `kubectl logs -n elasticsearch-rag elasticsearch-0`

### RAG pipeline errors
- Verify Elasticsearch is accessible
- Check embedding model download (first run may take time)
- Check logs: `kubectl logs -n elasticsearch-rag deployment/rag-pipeline`

### Search not working
- Verify index exists: `curl http://localhost:9200/_cat/indices`
- Check index mapping: `curl http://localhost:9200/rag-documents/_mapping`

