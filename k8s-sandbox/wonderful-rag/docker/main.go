package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"mime/multipart"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"sync"
	"syscall"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/aws/aws-sdk-go/service/s3/s3manager"
	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"
)

var (
	logger           *logrus.Logger
	awsSession       *session.Session
	s3Client         *s3.S3
	wonderfulAPIURL  string
	wonderfulRAGID   string
	wonderfulAPIKey  string
	s3Bucket         string
	s3Prefix         string
	syncInterval     time.Duration
	processedFiles   map[string]bool
	processedFilesMu sync.RWMutex
)

func init() {
	logger = logrus.New()
	logger.SetFormatter(&logrus.JSONFormatter{})
	logger.SetLevel(logrus.InfoLevel)
	processedFiles = make(map[string]bool)
}

func main() {
	// Load configuration
	awsRegion := getEnv("AWS_REGION", "us-east-1")
	awsAccessKeyID := getEnv("AWS_ACCESS_KEY_ID", "")
	awsSecretAccessKey := getEnv("AWS_SECRET_ACCESS_KEY", "")
	s3Bucket = getEnv("S3_BUCKET", "")
	s3Prefix = getEnv("S3_PREFIX", "")
	wonderfulAPIURL = getEnv("WONDERFUL_API_URL", "https://swiss-german.app.sb.wonderful.ai")
	wonderfulRAGID = getEnv("WONDERFUL_RAG_ID", "")
	wonderfulAPIKey = getEnv("WONDERFUL_API_KEY", "")
	intervalMinutes := getEnv("SYNC_INTERVAL_MINUTES", "30")
	port := getEnv("PORT", "8080")

	// Validate required configuration
	if s3Bucket == "" {
		logger.Fatal("S3_BUCKET is required")
	}
	if wonderfulRAGID == "" {
		logger.Fatal("WONDERFUL_RAG_ID is required")
	}
	if wonderfulAPIKey == "" {
		logger.Fatal("WONDERFUL_API_KEY is required")
	}

	// Parse sync interval
	interval, err := time.ParseDuration(intervalMinutes + "m")
	if err != nil {
		logger.Fatalf("Invalid SYNC_INTERVAL_MINUTES: %v", err)
	}
	syncInterval = interval

	// Initialize AWS session
	awsConfig := &aws.Config{
		Region: aws.String(awsRegion),
	}

	if awsAccessKeyID != "" && awsSecretAccessKey != "" {
		awsConfig.Credentials = credentials.NewStaticCredentials(
			awsAccessKeyID,
			awsSecretAccessKey,
			"",
		)
	}

	awsSession, err = session.NewSession(awsConfig)
	if err != nil {
		logger.Fatalf("Failed to create AWS session: %v", err)
	}

	s3Client = s3.New(awsSession)
	logger.Info("AWS S3 client initialized")

	// Start background sync job
	go syncS3ToWonderful()

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
		api.POST("/sync", triggerSync)
		api.GET("/stats", getStats)
		api.GET("/processed-files", getProcessedFiles)
	}

	return router
}

func healthHandler(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status": "healthy",
		"service": "wonderful-rag-sync",
		"s3_bucket": s3Bucket,
		"wonderful_api": wonderfulAPIURL,
	})
}

func triggerSync(c *gin.Context) {
	go syncS3ToWonderful()
	c.JSON(http.StatusOK, gin.H{
		"message": "Sync triggered",
		"status": "started",
	})
}

func getStats(c *gin.Context) {
	processedFilesMu.RLock()
	count := len(processedFiles)
	processedFilesMu.RUnlock()

	c.JSON(http.StatusOK, gin.H{
		"processed_files": count,
		"s3_bucket": s3Bucket,
		"s3_prefix": s3Prefix,
		"sync_interval_minutes": syncInterval.Minutes(),
	})
}

func getProcessedFiles(c *gin.Context) {
	processedFilesMu.RLock()
	files := make([]string, 0, len(processedFiles))
	for file := range processedFiles {
		files = append(files, file)
	}
	processedFilesMu.RUnlock()

	c.JSON(http.StatusOK, gin.H{
		"files": files,
		"count": len(files),
	})
}

func syncS3ToWonderful() {
	logger.Info("Starting S3 to Wonderful API sync...")

	ctx := context.Background()

	// List objects in S3 bucket
	listInput := &s3.ListObjectsV2Input{
		Bucket: aws.String(s3Bucket),
	}

	if s3Prefix != "" {
		listInput.Prefix = aws.String(s3Prefix)
	}

	downloader := s3manager.NewDownloader(awsSession)
	uploader := s3manager.NewUploader(awsSession)

	successCount := 0
	errorCount := 0
	errors := []string{}

	// List all objects
	err := s3Client.ListObjectsV2PagesWithContext(ctx, listInput, func(page *s3.ListObjectsV2Output, lastPage bool) bool {
		for _, obj := range page.Contents {
			key := *obj.Key

			// Skip if already processed
			processedFilesMu.RLock()
			if processedFiles[key] {
				processedFilesMu.RUnlock()
				logger.Debugf("Skipping already processed file: %s", key)
				continue
			}
			processedFilesMu.RUnlock()

			logger.Infof("Processing file: %s", key)

			// Download file from S3
			buf := aws.NewWriteAtBuffer([]byte{})
			_, err := downloader.Download(buf, &s3.GetObjectInput{
				Bucket: aws.String(s3Bucket),
				Key:    aws.String(key),
			})

			if err != nil {
				logger.Errorf("Failed to download %s: %v", key, err)
				errorCount++
				errors = append(errors, fmt.Sprintf("%s: download failed - %v", key, err))
				continue
			}

			// Upload to Wonderful API
			fileContent := buf.Bytes()
			fileName := key
			if lastSlash := strings.LastIndex(key, "/"); lastSlash >= 0 {
				fileName = key[lastSlash+1:]
			}

			fileID, err := uploadToWonderful(fileName, fileContent, key)
			if err != nil {
				logger.Errorf("Failed to upload %s to Wonderful API: %v", key, err)
				errorCount++
				errors = append(errors, fmt.Sprintf("%s: upload failed - %v", key, err))
				continue
			}

			// Mark as processed
			processedFilesMu.Lock()
			processedFiles[key] = true
			processedFilesMu.Unlock()

			logger.Infof("Successfully processed %s (Wonderful file ID: %s)", key, fileID)
			successCount++
		}
		return true
	})

	if err != nil {
		logger.Errorf("Error listing S3 objects: %v", err)
		return
	}

	logger.Infof("Sync completed: %d succeeded, %d failed", successCount, errorCount)
	if len(errors) > 0 {
		logger.Warnf("Errors: %v", errors)
	}

	// Clean up unused variable
	_ = uploader
}

func uploadToWonderful(fileName string, fileContent []byte, s3Key string) (string, error) {
	// First, upload the file to get a file_id
	uploadURL := fmt.Sprintf("%s/api/v1/rags/%s/files", wonderfulAPIURL, wonderfulRAGID)

	// Create multipart form
	body := &bytes.Buffer{}
	writer := multipart.NewWriter(body)

	// Add file
	part, err := writer.CreateFormFile("file", fileName)
	if err != nil {
		return "", fmt.Errorf("failed to create form file: %w", err)
	}

	_, err = part.Write(fileContent)
	if err != nil {
		return "", fmt.Errorf("failed to write file content: %w", err)
	}

	// Add metadata
	writer.WriteField("source", "s3")
	writer.WriteField("s3_key", s3Key)
	writer.WriteField("s3_bucket", s3Bucket)

	err = writer.Close()
	if err != nil {
		return "", fmt.Errorf("failed to close multipart writer: %w", err)
	}

	// Create request
	req, err := http.NewRequest("POST", uploadURL, body)
	if err != nil {
		return "", fmt.Errorf("failed to create request: %w", err)
	}

	req.Header.Set("Content-Type", writer.FormDataContentType())
	req.Header.Set("Authorization", "Bearer "+wonderfulAPIKey)

	// Execute request
	client := &http.Client{
		Timeout: 30 * time.Second,
	}

	resp, err := client.Do(req)
	if err != nil {
		return "", fmt.Errorf("failed to execute request: %w", err)
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("failed to read response: %w", err)
	}

	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusCreated {
		return "", fmt.Errorf("API returned status %d: %s", resp.StatusCode, string(respBody))
	}

	// Parse response to get file_id
	var result map[string]interface{}
	if err := json.Unmarshal(respBody, &result); err != nil {
		// If response doesn't have JSON, return the S3 key as identifier
		return s3Key, nil
	}

	if fileID, ok := result["file_id"].(string); ok {
		return fileID, nil
	}

	if id, ok := result["id"].(string); ok {
		return id, nil
	}

	// Fallback to S3 key
	return s3Key, nil
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

