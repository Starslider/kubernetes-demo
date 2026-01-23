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
	logger.SetLevel(logrus.DebugLevel) // Verbose logging
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
	intervalSeconds := getEnv("SYNC_INTERVAL_SECONDS", "")
	intervalMinutes := getEnv("SYNC_INTERVAL_MINUTES", "") // Fallback for backward compatibility
	port := getEnv("PORT", "8080")

	logger.Info("=== Wonderful RAG S3 Sync Service Starting ===")
	logger.Infof("Configuration loaded - S3 Bucket: %s, Prefix: %s", s3Bucket, s3Prefix)
	logger.Debugf("Wonderful API URL: %s", wonderfulAPIURL)
	logger.Debugf("Wonderful RAG ID: %s", wonderfulRAGID)

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

	// Parse sync interval (prefer seconds, fallback to minutes)
	var interval time.Duration
	var err error
	if intervalSeconds != "" {
		interval, err = time.ParseDuration(intervalSeconds + "s")
		if err != nil {
			logger.Fatalf("Invalid SYNC_INTERVAL_SECONDS: %v", err)
		}
		logger.Infof("Sync interval set to %v (from SYNC_INTERVAL_SECONDS)", interval)
	} else if intervalMinutes != "" {
		interval, err = time.ParseDuration(intervalMinutes + "m")
		if err != nil {
			logger.Fatalf("Invalid SYNC_INTERVAL_MINUTES: %v", err)
		}
		logger.Infof("Sync interval set to %v (from SYNC_INTERVAL_MINUTES)", interval)
	} else {
		interval = 30 * time.Minute
		logger.Warnf("No sync interval specified, using default: %v", interval)
	}
	syncInterval = interval

	// Initialize AWS session
	logger.Info("=== Initializing AWS Session ===")
	logger.Debugf("AWS Region: %s", awsRegion)
	
	awsConfig := &aws.Config{
		Region: aws.String(awsRegion),
	}

	if awsAccessKeyID != "" && awsSecretAccessKey != "" {
		logger.Info("Using AWS Access Key credentials for authentication")
		keyIDMasked := awsAccessKeyID
		if len(keyIDMasked) > 8 {
			keyIDMasked = keyIDMasked[:4] + "..." + keyIDMasked[len(keyIDMasked)-4:]
		} else if len(keyIDMasked) > 0 {
			keyIDMasked = "***"
		}
		logger.Debugf("AWS Access Key ID: %s (length: %d)", keyIDMasked, len(awsAccessKeyID))
		awsConfig.Credentials = credentials.NewStaticCredentials(
			awsAccessKeyID,
			awsSecretAccessKey,
			"",
		)
	} else {
		logger.Info("No AWS credentials provided, using IAM role or default credentials chain")
	}

	awsSession, err = session.NewSession(awsConfig)
	if err != nil {
		logger.Fatalf("Failed to create AWS session: %v", err)
	}
	logger.Info("✓ AWS session created successfully")

	s3Client = s3.New(awsSession)
	logger.Info("✓ AWS S3 client initialized")
	
	// Test S3 connection
	logger.Debug("Testing S3 connection...")
	_, err = s3Client.HeadBucket(&s3.HeadBucketInput{
		Bucket: aws.String(s3Bucket),
	})
	if err != nil {
		logger.Warnf("S3 bucket head check failed (may be expected): %v", err)
	} else {
		logger.Infof("✓ Successfully connected to S3 bucket: %s", s3Bucket)
	}

	// Start background sync job
	logger.Info("Starting background sync job...")
	go func() {
		// Initial sync
		logger.Info("Performing initial sync...")
		syncS3ToWonderful()
		
		// Periodic sync
		ticker := time.NewTicker(syncInterval)
		defer ticker.Stop()
		
		logger.Infof("Starting periodic sync (interval: %v)", syncInterval)
		for range ticker.C {
			logger.Debugf("Sync interval reached (%v), triggering sync...", syncInterval)
			syncS3ToWonderful()
		}
	}()

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
	logger.Info("=== Starting S3 to Wonderful API Sync ===")
	syncStartTime := time.Now()
	
	ctx := context.Background()

	// List objects in S3 bucket
	logger.Debugf("Preparing to list objects in bucket: %s", s3Bucket)
	listInput := &s3.ListObjectsV2Input{
		Bucket: aws.String(s3Bucket),
	}

	if s3Prefix != "" {
		listInput.Prefix = aws.String(s3Prefix)
		logger.Debugf("Using S3 prefix filter: %s", s3Prefix)
	}

	logger.Debug("Initializing S3 downloader and uploader...")
	downloader := s3manager.NewDownloader(awsSession)
	uploader := s3manager.NewUploader(awsSession)
	logger.Debug("✓ S3 managers initialized")

	successCount := 0
	errorCount := 0
	skippedCount := 0
	totalFilesFound := 0
	errors := []string{}

	logger.Info("Scanning S3 bucket for files...")
	
	// List all objects
	err := s3Client.ListObjectsV2PagesWithContext(ctx, listInput, func(page *s3.ListObjectsV2Output, lastPage bool) bool {
		logger.Debugf("Processing page with %d objects (lastPage: %v)", len(page.Contents), lastPage)
		
		for _, obj := range page.Contents {
			key := *obj.Key
			size := *obj.Size
			totalFilesFound++

			logger.Debugf("Found file: %s (size: %d bytes, modified: %v)", key, size, obj.LastModified)

			// Skip if already processed
			processedFilesMu.RLock()
			if processedFiles[key] {
				processedFilesMu.RUnlock()
				logger.Debugf("⏭️  Skipping already processed file: %s", key)
				skippedCount++
				continue
			}
			processedFilesMu.RUnlock()

			logger.Infof("📄 Processing file: %s (size: %d bytes)", key, size)

			// Download file from S3
			logger.Debugf("  → Downloading from S3: s3://%s/%s", s3Bucket, key)
			downloadStart := time.Now()
			buf := aws.NewWriteAtBuffer([]byte{})
			bytesDownloaded, err := downloader.Download(buf, &s3.GetObjectInput{
				Bucket: aws.String(s3Bucket),
				Key:    aws.String(key),
			})
			downloadDuration := time.Since(downloadStart)

			if err != nil {
				logger.Errorf("  ✗ Failed to download %s: %v", key, err)
				errorCount++
				errors = append(errors, fmt.Sprintf("%s: download failed - %v", key, err))
				continue
			}
			logger.Debugf("  ✓ Downloaded %d bytes in %v", bytesDownloaded, downloadDuration)

			// Upload to Wonderful API
			fileContent := buf.Bytes()
			fileName := key
			if lastSlash := strings.LastIndex(key, "/"); lastSlash >= 0 {
				fileName = key[lastSlash+1:]
			}

			logger.Debugf("  → Uploading to Wonderful API: %s/api/v1/rags/%s/files", wonderfulAPIURL, wonderfulRAGID)
			uploadStart := time.Now()
			fileID, err := uploadToWonderful(fileName, fileContent, key)
			uploadDuration := time.Since(uploadStart)

			if err != nil {
				logger.Errorf("  ✗ Failed to upload %s to Wonderful API: %v", key, err)
				errorCount++
				errors = append(errors, fmt.Sprintf("%s: upload failed - %v", key, err))
				continue
			}

			// Mark as processed
			processedFilesMu.Lock()
			processedFiles[key] = true
			processedFilesMu.Unlock()

			logger.Infof("  ✓ Successfully processed %s (Wonderful file ID: %s, upload took %v)", key, fileID, uploadDuration)
			successCount++
		}
		
		logger.Debugf("Page processed. Total files found so far: %d", totalFilesFound)
		return true
	})

	if err != nil {
		logger.Errorf("✗ Error listing S3 objects: %v", err)
		return
	}

	syncDuration := time.Since(syncStartTime)
	logger.Info("=== Sync Completed ===")
	logger.Infof("Summary:")
	logger.Infof("  Total files found: %d", totalFilesFound)
	logger.Infof("  Successfully processed: %d", successCount)
	logger.Infof("  Skipped (already processed): %d", skippedCount)
	logger.Infof("  Failed: %d", errorCount)
	logger.Infof("  Duration: %v", syncDuration)
	
	if len(errors) > 0 {
		logger.Warnf("Errors encountered:")
		for i, errMsg := range errors {
			logger.Warnf("  %d. %s", i+1, errMsg)
		}
	}

	// Clean up unused variable
	_ = uploader
}

func uploadToWonderful(fileName string, fileContent []byte, s3Key string) (string, error) {
	logger.Debugf("    Preparing upload to Wonderful API...")
	
	// First, upload the file to get a file_id
	uploadURL := fmt.Sprintf("%s/api/v1/rags/%s/files", wonderfulAPIURL, wonderfulRAGID)
	logger.Debugf("    Upload URL: %s", uploadURL)
	logger.Debugf("    File name: %s, Size: %d bytes", fileName, len(fileContent))

	// Create multipart form
	logger.Debugf("    Creating multipart form data...")
	body := &bytes.Buffer{}
	writer := multipart.NewWriter(body)

	// Add file
	part, err := writer.CreateFormFile("file", fileName)
	if err != nil {
		logger.Errorf("    ✗ Failed to create form file: %v", err)
		return "", fmt.Errorf("failed to create form file: %w", err)
	}

	_, err = part.Write(fileContent)
	if err != nil {
		logger.Errorf("    ✗ Failed to write file content: %v", err)
		return "", fmt.Errorf("failed to write file content: %w", err)
	}
	logger.Debugf("    ✓ File content written to form")

	// Add metadata
	logger.Debugf("    Adding metadata fields...")
	writer.WriteField("source", "s3")
	writer.WriteField("s3_key", s3Key)
	writer.WriteField("s3_bucket", s3Bucket)
	logger.Debugf("    ✓ Metadata added: source=s3, s3_key=%s, s3_bucket=%s", s3Key, s3Bucket)

	err = writer.Close()
	if err != nil {
		logger.Errorf("    ✗ Failed to close multipart writer: %v", err)
		return "", fmt.Errorf("failed to close multipart writer: %w", err)
	}

	// Create request
	logger.Debugf("    Creating HTTP request...")
	req, err := http.NewRequest("POST", uploadURL, body)
	if err != nil {
		logger.Errorf("    ✗ Failed to create request: %v", err)
		return "", fmt.Errorf("failed to create request: %w", err)
	}

	contentType := writer.FormDataContentType()
	req.Header.Set("Content-Type", contentType)
	req.Header.Set("Authorization", "Bearer "+wonderfulAPIKey)
	logger.Debugf("    ✓ Request created with Content-Type: %s", contentType)
	logger.Debugf("    ✓ Authorization header set (API key length: %d)", len(wonderfulAPIKey))

	// Execute request
	logger.Debugf("    Sending request to Wonderful API...")
	client := &http.Client{
		Timeout: 30 * time.Second,
	}

	resp, err := client.Do(req)
	if err != nil {
		logger.Errorf("    ✗ Request failed: %v", err)
		return "", fmt.Errorf("failed to execute request: %w", err)
	}
	defer resp.Body.Close()

	logger.Debugf("    ✓ Received response: Status %d %s", resp.StatusCode, resp.Status)
	
	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		logger.Errorf("    ✗ Failed to read response body: %v", err)
		return "", fmt.Errorf("failed to read response: %w", err)
	}

	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusCreated {
		logger.Errorf("    ✗ API returned error status %d: %s", resp.StatusCode, string(respBody))
		return "", fmt.Errorf("API returned status %d: %s", resp.StatusCode, string(respBody))
	}

	logger.Debugf("    ✓ Upload successful, parsing response...")

	// Parse response to get file_id
	var result map[string]interface{}
	if err := json.Unmarshal(respBody, &result); err != nil {
		logger.Debugf("    Response is not JSON, using S3 key as identifier")
		// If response doesn't have JSON, return the S3 key as identifier
		return s3Key, nil
	}

	if fileID, ok := result["file_id"].(string); ok {
		logger.Debugf("    ✓ File ID from response: %s", fileID)
		return fileID, nil
	}

	if id, ok := result["id"].(string); ok {
		logger.Debugf("    ✓ ID from response: %s", id)
		return id, nil
	}

	logger.Debugf("    No file_id or id in response, using S3 key as fallback")
	// Fallback to S3 key
	return s3Key, nil
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}

func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}

