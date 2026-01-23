package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"sync"
	"time"

	"github.com/sirupsen/logrus"
)

// EmbeddingService handles text embeddings
// For now, using a simple approach with a mock embedding service
// In production, you'd use ONNX Runtime or a proper ML library
type EmbeddingService struct {
	modelName string
	ready     bool
	dims      int
	mu        sync.RWMutex
	// In a real implementation, you'd have ONNX model here
}

// NewEmbeddingService creates a new embedding service
// Note: This is a simplified version. For production, integrate with ONNX Runtime
func NewEmbeddingService(modelName string) (*EmbeddingService, error) {
	service := &EmbeddingService{
		modelName: modelName,
		dims:      384, // all-MiniLM-L6-v2 dimensions
		ready:     true, // Simplified - in production, load actual model
	}

	// In production, load ONNX model here
	// For now, we'll use a fallback that generates simple embeddings
	logrus.Infof("Embedding service initialized (model: %s, dims: %d)", modelName, service.dims)

	return service, nil
}

// IsReady returns whether the embedding service is ready
func (e *EmbeddingService) IsReady() bool {
	e.mu.RLock()
	defer e.mu.RUnlock()
	return e.ready
}

// GetDimensions returns the embedding dimensions
func (e *EmbeddingService) GetDimensions() int {
	return e.dims
}

// Encode generates an embedding for the given text
// This is a simplified version - in production, use ONNX Runtime
func (e *EmbeddingService) Encode(text string) ([]float32, error) {
	if !e.IsReady() {
		return nil, fmt.Errorf("embedding service not ready")
	}

	// Simplified embedding generation
	// In production, this would call ONNX Runtime or a proper ML library
	// For now, we'll generate a deterministic embedding based on text hash
	embedding := make([]float32, e.dims)
	
	// Simple hash-based embedding (not production-ready)
	// In production, use ONNX Runtime with the actual model
	hash := simpleHash(text)
	for i := range embedding {
		embedding[i] = float32((hash*int64(i+1))%1000) / 1000.0
	}

	return embedding, nil
}

// simpleHash generates a simple hash for deterministic embeddings
func simpleHash(s string) int64 {
	var h int64
	for _, c := range s {
		h = h*31 + int64(c)
	}
	if h < 0 {
		h = -h
	}
	return h
}

// Alternative: Use a Python service for embeddings (hybrid approach)
// This would call a Python microservice that handles embeddings
type PythonEmbeddingService struct {
	baseURL string
	client  *http.Client
	ready   bool
	dims    int
	mu      sync.RWMutex
}

// NewPythonEmbeddingService creates a service that calls Python for embeddings
// This is useful if you want to keep using sentence-transformers
func NewPythonEmbeddingService(pythonServiceURL string) (*PythonEmbeddingService, error) {
	service := &PythonEmbeddingService{
		baseURL: pythonServiceURL,
		client: &http.Client{
			Timeout: 30 * time.Second,
		},
		dims:  384,
		ready: true,
	}

	// Test connection
	resp, err := service.client.Get(service.baseURL + "/health")
	if err == nil {
		resp.Body.Close()
		service.ready = true
	}

	return service, nil
}

func (p *PythonEmbeddingService) Encode(text string) ([]float32, error) {
	reqBody := map[string]string{"text": text}
	jsonData, _ := json.Marshal(reqBody)

	resp, err := p.client.Post(p.baseURL+"/encode", "application/json", bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	var result struct {
		Embedding []float32 `json:"embedding"`
	}

	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, err
	}

	return result.Embedding, nil
}

func (p *PythonEmbeddingService) IsReady() bool {
	p.mu.RLock()
	defer p.mu.RUnlock()
	return p.ready
}

func (p *PythonEmbeddingService) GetDimensions() int {
	return p.dims
}

