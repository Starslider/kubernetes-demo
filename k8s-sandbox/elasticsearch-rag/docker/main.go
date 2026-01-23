package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/elastic/go-elasticsearch/v8"
	"github.com/elastic/go-elasticsearch/v8/esapi"
	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"
)

var (
	esClient    *elasticsearch.Client
	embedder    *EmbeddingService
	esIndex     string
	esReady     bool
	logger      *logrus.Logger
)

func init() {
	logger = logrus.New()
	logger.SetFormatter(&logrus.JSONFormatter{})
	logger.SetLevel(logrus.InfoLevel)
}

func main() {
	// Load configuration
	esHost := getEnv("ELASTICSEARCH_HOST", "elasticsearch.elasticsearch-rag.svc.cluster.local")
	esPort := getEnv("ELASTICSEARCH_PORT", "9200")
	esIndex = getEnv("ELASTICSEARCH_INDEX", "rag-documents")
	embeddingModel := getEnv("EMBEDDING_MODEL", "all-MiniLM-L6-v2")
	port := getEnv("PORT", "8080")

	// Initialize Elasticsearch client
	cfg := elasticsearch.Config{
		Addresses: []string{
			fmt.Sprintf("http://%s:%s", esHost, esPort),
		},
	}

	var err error
	esClient, err = elasticsearch.NewClient(cfg)
	if err != nil {
		logger.Fatalf("Error creating Elasticsearch client: %v", err)
	}

	// Initialize embedding service
	embedder, err = NewEmbeddingService(embeddingModel)
	if err != nil {
		logger.Fatalf("Error initializing embedding service: %v", err)
	}
	logger.Info("Embedding service initialized successfully")

	// Initialize index in background
	go ensureIndex()

	// Setup HTTP server
	router := setupRouter()

	srv := &http.Server{
		Addr:    ":" + port,
		Handler: router,
	}

	// Start server in goroutine
	go func() {
		logger.Infof("Starting server on port %s", port)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			logger.Fatalf("Failed to start server: %v", err)
		}
	}()

	// Wait for interrupt signal
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	logger.Info("Shutting down server...")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		logger.Fatalf("Server forced to shutdown: %v", err)
	}

	logger.Info("Server exited")
}

func setupRouter() *gin.Engine {
	router := gin.Default()
	router.Use(gin.Logger(), gin.Recovery())

	// Health check
	router.GET("/health", healthHandler)

	// API routes
	api := router.Group("/api/v1")
	{
		api.POST("/index", indexDocument)
		api.POST("/search", searchDocuments)
		api.POST("/batch-index", batchIndex)
		api.GET("/stats", getStats)
	}

	return router
}

func healthHandler(c *gin.Context) {
	// Check Elasticsearch connection
	esStatus := false
	res, err := esClient.Ping()
	if err == nil && res.StatusCode == 200 {
		esStatus = true
	}

	modelReady := embedder != nil && embedder.IsReady()

	status := "starting"
	httpStatus := http.StatusOK

	if esStatus && modelReady {
		status = "healthy"
	} else if !esStatus || !modelReady {
		status = "starting"
	}

	c.JSON(httpStatus, gin.H{
		"status":         status,
		"app":            "ready",
		"elasticsearch":  map[string]interface{}{"connected": esStatus},
		"embedding_model": map[string]interface{}{"loaded": modelReady},
	})
}

func indexDocument(c *gin.Context) {
	var req struct {
		Text     string                 `json:"text" binding:"required"`
		Metadata map[string]interface{} `json:"metadata"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing 'text' field"})
		return
	}

	if !esReady {
		c.JSON(http.StatusServiceUnavailable, gin.H{"error": "Elasticsearch is not ready"})
		return
	}

	// Generate embedding
	embedding32, err := embedder.Encode(req.Text)
	if err != nil {
		logger.Errorf("Error generating embedding: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate embedding"})
		return
	}

	// Convert float32 to float64 for Elasticsearch
	embedding := make([]float64, len(embedding32))
	for i, v := range embedding32 {
		embedding[i] = float64(v)
	}

	// Create document
	doc := map[string]interface{}{
		"text":      req.Text,
		"metadata":  req.Metadata,
		"embedding": embedding,
		"timestamp": time.Now().Format(time.RFC3339),
	}

	docJSON, _ := json.Marshal(doc)

	// Index document
	indexReq := esapi.IndexRequest{
		Index:      esIndex,
		DocumentID: "",
		Body:       bytes.NewReader(docJSON),
		Refresh:    "true",
	}

	res, err := indexReq.Do(context.Background(), esClient)
	if err != nil {
		logger.Errorf("Error indexing document: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	defer res.Body.Close()

	var result map[string]interface{}
	if err := json.NewDecoder(res.Body).Decode(&result); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse response"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"id":      result["_id"],
		"index":   result["_index"],
	})
}

func searchDocuments(c *gin.Context) {
	var req struct {
		Query string `json:"query" binding:"required"`
		TopK  int    `json:"top_k"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing 'query' field"})
		return
	}

	if req.TopK == 0 {
		req.TopK = 5
	}

	if !esReady {
		c.JSON(http.StatusServiceUnavailable, gin.H{"error": "Elasticsearch is not ready"})
		return
	}

	// Generate query embedding
	queryEmbedding32, err := embedder.Encode(req.Query)
	if err != nil {
		logger.Errorf("Error generating embedding: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate embedding"})
		return
	}

	// Convert float32 to float64 for Elasticsearch
	queryEmbedding := make([]float64, len(queryEmbedding32))
	for i, v := range queryEmbedding32 {
		queryEmbedding[i] = float64(v)
	}

	// Build kNN search query
	searchBody := map[string]interface{}{
		"knn": map[string]interface{}{
			"field":          "embedding",
			"query_vector":   queryEmbedding,
			"k":              req.TopK,
			"num_candidates": req.TopK * 10,
		},
		"_source": []string{"text", "metadata", "timestamp"},
	}

	searchJSON, _ := json.Marshal(searchBody)

	// Execute search
	searchReq := esapi.SearchRequest{
		Index: []string{esIndex},
		Body:  bytes.NewReader(searchJSON),
	}

	res, err := searchReq.Do(context.Background(), esClient)
	if err != nil {
		logger.Errorf("Error searching: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	defer res.Body.Close()

	var searchResult map[string]interface{}
	if err := json.NewDecoder(res.Body).Decode(&searchResult); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse response"})
		return
	}

	// Format results
	hits := []map[string]interface{}{}
	if hitsData, ok := searchResult["hits"].(map[string]interface{}); ok {
		if hitsArray, ok := hitsData["hits"].([]interface{}); ok {
			for _, hit := range hitsArray {
				if hitMap, ok := hit.(map[string]interface{}); ok {
					source := map[string]interface{}{}
					if src, ok := hitMap["_source"].(map[string]interface{}); ok {
						source = src
					}
					hits = append(hits, map[string]interface{}{
						"id":        hitMap["_id"],
						"score":     hitMap["_score"],
						"text":      source["text"],
						"metadata":  source["metadata"],
						"timestamp": source["timestamp"],
					})
				}
			}
		}
	}

	total := 0
	if hitsData, ok := searchResult["hits"].(map[string]interface{}); ok {
		if totalData, ok := hitsData["total"].(map[string]interface{}); ok {
			if val, ok := totalData["value"].(float64); ok {
				total = int(val)
			}
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"query":   req.Query,
		"results": hits,
		"total":   total,
	})
}

func batchIndex(c *gin.Context) {
	var req struct {
		Documents []struct {
			Text     string                 `json:"text" binding:"required"`
			Metadata map[string]interface{} `json:"metadata"`
		} `json:"documents" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing 'documents' array"})
		return
	}

	if !esReady {
		c.JSON(http.StatusServiceUnavailable, gin.H{"error": "Elasticsearch is not ready"})
		return
	}

	successCount := 0
	errorCount := 0
	errors := []string{}

		for _, doc := range req.Documents {
			// Generate embedding
			embedding32, err := embedder.Encode(doc.Text)
			if err != nil {
				errorCount++
				errors = append(errors, fmt.Sprintf("Error generating embedding: %v", err))
				continue
			}

			// Convert float32 to float64 for Elasticsearch
			embedding := make([]float64, len(embedding32))
			for i, v := range embedding32 {
				embedding[i] = float64(v)
			}

			// Create document
			esDoc := map[string]interface{}{
				"text":      doc.Text,
				"metadata":  doc.Metadata,
				"embedding": embedding,
				"timestamp": time.Now().Format(time.RFC3339),
			}

		docJSON, _ := json.Marshal(esDoc)

		// Index document
		indexReq := esapi.IndexRequest{
			Index:      esIndex,
			DocumentID: "",
			Body:       bytes.NewReader(docJSON),
			Refresh:    "false",
		}

		_, err = indexReq.Do(context.Background(), esClient)
		if err != nil {
			errorCount++
			errors = append(errors, fmt.Sprintf("Error indexing: %v", err))
			continue
		}

		successCount++
	}

	c.JSON(http.StatusOK, gin.H{
		"success":  true,
		"processed": successCount,
		"failed":    errorCount,
		"total":     len(req.Documents),
		"errors":    errors,
	})
}

func getStats(c *gin.Context) {
	if !esReady {
		c.JSON(http.StatusServiceUnavailable, gin.H{"error": "Elasticsearch is not ready"})
		return
	}

	// Get count
	countReq := esapi.CountRequest{Index: []string{esIndex}}
	countRes, err := countReq.Do(context.Background(), esClient)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	defer countRes.Body.Close()

	var countResult map[string]interface{}
	json.NewDecoder(countRes.Body).Decode(&countResult)

	// Get stats
	statsReq := esapi.IndicesStatsRequest{Index: []string{esIndex}}
	statsRes, err := statsReq.Do(context.Background(), esClient)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	defer statsRes.Body.Close()

	var statsResult map[string]interface{}
	json.NewDecoder(statsRes.Body).Decode(&statsResult)

	docCount := 0
	if count, ok := countResult["count"].(float64); ok {
		docCount = int(count)
	}

	indexSize := int64(0)
	if indices, ok := statsResult["indices"].(map[string]interface{}); ok {
		if indexData, ok := indices[esIndex].(map[string]interface{}); ok {
			if total, ok := indexData["total"].(map[string]interface{}); ok {
				if store, ok := total["store"].(map[string]interface{}); ok {
					if size, ok := store["size_in_bytes"].(float64); ok {
						indexSize = int64(size)
					}
				}
			}
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"index":         esIndex,
		"document_count": docCount,
		"index_size":    indexSize,
	})
}

func ensureIndex() {
	maxRetries := 30
	retryCount := 0

	for retryCount < maxRetries {
		// Check if Elasticsearch is ready
		res, err := esClient.Ping()
		if err != nil || res.StatusCode != 200 {
			logger.Warnf("Elasticsearch not ready, retrying... (attempt %d/%d)", retryCount+1, maxRetries)
			retryCount++
			time.Sleep(2 * time.Second)
			continue
		}

		// Check if index exists
		existsReq := esapi.IndicesExistsRequest{Index: []string{esIndex}}
		existsRes, err := existsReq.Do(context.Background(), esClient)
		if err == nil && existsRes.StatusCode == 200 {
			logger.Infof("Index %s already exists", esIndex)
			esReady = true
			return
		}

		// Create index with mapping
		if embedder.IsReady() {
			dims := embedder.GetDimensions()
			mapping := map[string]interface{}{
				"mappings": map[string]interface{}{
					"properties": map[string]interface{}{
						"text": map[string]interface{}{
							"type": "text",
						},
						"metadata": map[string]interface{}{
							"type": "object",
						},
						"embedding": map[string]interface{}{
							"type":    "dense_vector",
							"dims":    dims,
						},
						"timestamp": map[string]interface{}{
							"type": "date",
						},
					},
				},
			}

			mappingJSON, _ := json.Marshal(mapping)
			createReq := esapi.IndicesCreateRequest{
				Index: esIndex,
				Body:  bytes.NewReader(mappingJSON),
			}

			createRes, err := createReq.Do(context.Background(), esClient)
			if err == nil && createRes.StatusCode == 200 {
				logger.Infof("Created index: %s", esIndex)
				esReady = true
				return
			}
		}

		retryCount++
		time.Sleep(2 * time.Second)
	}

	logger.Error("Failed to ensure index exists after max retries")
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

