package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
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
	maxFileSize      int64 // Maximum file size in bytes (0 = no limit)
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
	s3PrefixRaw := getEnv("S3_PREFIX", "")
	// Normalize prefix: remove leading/trailing slashes, empty string means root
	s3Prefix = strings.Trim(s3PrefixRaw, "/")
	if s3Prefix == "" {
		logger.Debug("S3 prefix is empty - will list files from root of bucket")
	} else {
		logger.Debugf("S3 prefix normalized: '%s' -> '%s'", s3PrefixRaw, s3Prefix)
	}
	wonderfulAPIURL = getEnv("WONDERFUL_API_URL", "https://swiss-german.api.sb.wonderful.ai")
	wonderfulRAGID = getEnv("WONDERFUL_RAG_ID", "")
	wonderfulAPIKey = getEnv("WONDERFUL_API_KEY", "")
	intervalSeconds := getEnv("SYNC_INTERVAL_SECONDS", "")
	intervalMinutes := getEnv("SYNC_INTERVAL_MINUTES", "") // Fallback for backward compatibility
	maxFileSizeMB := getEnv("MAX_FILE_SIZE_MB", "0") // 0 = no limit
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

	// Parse max file size
	if maxFileSizeMB != "0" && maxFileSizeMB != "" {
		var maxMB int64
		_, err := fmt.Sscanf(maxFileSizeMB, "%d", &maxMB)
		if err == nil && maxMB > 0 {
			maxFileSize = maxMB * 1024 * 1024 // Convert MB to bytes
			logger.Infof("Maximum file size limit: %d MB (%s)", maxMB, formatFileSize(maxFileSize))
		} else {
			logger.Warnf("Invalid MAX_FILE_SIZE_MB value '%s', ignoring limit", maxFileSizeMB)
			maxFileSize = 0
		}
	} else {
		maxFileSize = 0
		logger.Info("No file size limit configured (MAX_FILE_SIZE_MB not set or 0)")
	}

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
		logger.Debugf("Using S3 prefix filter: '%s'", s3Prefix)
	} else {
		logger.Debug("No S3 prefix specified - listing all files from bucket root")
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

			// Format file size for logging
			sizeStr := formatFileSize(size)
			logger.Debugf("Found file: %s (size: %s, modified: %v)", key, sizeStr, obj.LastModified)

			// Skip if already processed
			processedFilesMu.RLock()
			if processedFiles[key] {
				processedFilesMu.RUnlock()
				logger.Debugf("⏭️  Skipping already processed file: %s", key)
				skippedCount++
				continue
			}
			processedFilesMu.RUnlock()

			// Check file size limit
			if maxFileSize > 0 && size > maxFileSize {
				logger.Warnf("⚠️  Skipping file %s: size %s exceeds maximum allowed size %s", key, sizeStr, formatFileSize(maxFileSize))
				errorCount++
				errors = append(errors, fmt.Sprintf("%s: file too large (%s > %s)", key, sizeStr, formatFileSize(maxFileSize)))
				// Mark as processed to avoid retrying
				processedFilesMu.Lock()
				processedFiles[key] = true
				processedFilesMu.Unlock()
				continue
			}

			logger.Infof("📄 Processing file: %s (size: %s)", key, sizeStr)

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

			logger.Infof("  → Starting upload and attach process for: %s", key)
			uploadStart := time.Now()
			
			// uploadToWonderful performs both:
			// 1. Upload request (get pre-signed URL and upload to S3)
			// 2. Attach request (attach uploaded file to RAG)
			fileID, err := uploadToWonderful(fileName, fileContent, key)
			uploadDuration := time.Since(uploadStart)

			if err != nil {
				logger.Errorf("  ✗ Failed to process %s (upload or attach failed): %v", key, err)
				errorCount++
				errors = append(errors, fmt.Sprintf("%s: processing failed - %v", key, err))
				// Do NOT mark as processed if upload or attach failed
				continue
			}

			// Only mark as processed after BOTH upload and attach succeeded
			processedFilesMu.Lock()
			processedFiles[key] = true
			processedFilesMu.Unlock()

			logger.Infof("  ✓ Successfully processed %s (uploaded and attached to RAG, file ID: %s, took %v)", key, fileID, uploadDuration)
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
	logger.Debugf("    File name: %s, Size: %d bytes", fileName, len(fileContent))
	
	client := &http.Client{
		Timeout: 30 * time.Second,
	}

	// Step 1: Get pre-signed S3 URL from Wonderful API
	storageURL := fmt.Sprintf("%s/api/v1/storage", wonderfulAPIURL)
	logger.Debugf("    Step 1: Requesting pre-signed S3 URL from: %s", storageURL)
	
	// Determine content type from file extension
	contentType := "application/octet-stream"
	if strings.HasSuffix(strings.ToLower(fileName), ".json") {
		contentType = "application/json"
	} else if strings.HasSuffix(strings.ToLower(fileName), ".jpg") || strings.HasSuffix(strings.ToLower(fileName), ".jpeg") {
		contentType = "image/jpeg"
	} else if strings.HasSuffix(strings.ToLower(fileName), ".png") {
		contentType = "image/png"
	} else if strings.HasSuffix(strings.ToLower(fileName), ".pdf") {
		contentType = "application/pdf"
	} else if strings.HasSuffix(strings.ToLower(fileName), ".txt") {
		contentType = "text/plain"
	}
	
	// Create JSON payload for storage request
	storagePayload := map[string]interface{}{
		"contentType": contentType,
		"filename":    fileName,
	}
	
	storageBody, err := json.Marshal(storagePayload)
	if err != nil {
		logger.Errorf("    ✗ Failed to marshal storage request: %v", err)
		return "", fmt.Errorf("failed to marshal storage request: %w", err)
	}
	
	logger.Debugf("    ✓ Storage request payload: %s", string(storageBody))
	
	// Try POST method first (as per API spec)
	req, err := http.NewRequest("POST", storageURL, bytes.NewBuffer(storageBody))
	if err != nil {
		logger.Errorf("    ✗ Failed to create storage request: %v", err)
		return "", fmt.Errorf("failed to create storage request: %w", err)
	}
	
	req.Header.Set("Authorization", "Bearer "+wonderfulAPIKey)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")
	
	resp, err := client.Do(req)
	if err != nil {
		logger.Errorf("    ✗ Storage request failed: %v", err)
		return "", fmt.Errorf("failed to get pre-signed URL: %w", err)
	}
	defer resp.Body.Close()
	
	logger.Debugf("    ✓ Received storage response: Status %d %s", resp.StatusCode, resp.Status)
	
	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		logger.Errorf("    ✗ Failed to read storage response: %v", err)
		return "", fmt.Errorf("failed to read storage response: %w", err)
	}
	
	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusCreated {
		logger.Errorf("    ✗ Storage API returned error status %d: %s", resp.StatusCode, string(respBody))
		return "", fmt.Errorf("storage API returned status %d: %s", resp.StatusCode, string(respBody))
	}
	
	// Parse response to get pre-signed URL and file_id
	var storageResult map[string]interface{}
	if err := json.Unmarshal(respBody, &storageResult); err != nil {
		logger.Errorf("    ✗ Failed to parse storage response: %v", err)
		return "", fmt.Errorf("failed to parse storage response: %w", err)
	}
	
	presignedURL, ok := storageResult["url"].(string)
	if !ok {
		// Try alternative field names
		if url, ok := storageResult["presigned_url"].(string); ok {
			presignedURL = url
		} else if url, ok := storageResult["upload_url"].(string); ok {
			presignedURL = url
		} else {
			logger.Errorf("    ✗ No pre-signed URL found in response: %s", string(respBody))
			return "", fmt.Errorf("no pre-signed URL in storage response")
		}
	}
	
	fileID, _ := storageResult["file_id"].(string)
	if fileID == "" {
		if id, ok := storageResult["id"].(string); ok {
			fileID = id
		}
	}
	
	logger.Debugf("    ✓ Got pre-signed URL: %s", presignedURL)
	if fileID != "" {
		logger.Debugf("    ✓ Got file_id: %s", fileID)
	}

	// Step 2: Upload file directly to S3 using pre-signed URL
	logger.Infof("    Step 2: Uploading file to S3 using pre-signed URL...")
	
	uploadReq, err := http.NewRequest("PUT", presignedURL, bytes.NewReader(fileContent))
	if err != nil {
		logger.Errorf("    ✗ Failed to create S3 upload request: %v", err)
		return "", fmt.Errorf("failed to create S3 upload request: %w", err)
	}
	
	// Use the content type we determined earlier (or from storage response if provided)
	uploadContentType := contentType
	if respContentType, ok := storageResult["content_type"].(string); ok && respContentType != "" {
		uploadContentType = respContentType
	}
	uploadReq.Header.Set("Content-Type", uploadContentType)
	logger.Debugf("    ✓ Using Content-Type for S3 upload: %s", uploadContentType)
	
	uploadResp, err := http.DefaultClient.Do(uploadReq)
	if err != nil {
		logger.Errorf("    ✗ S3 upload failed: %v", err)
		return "", fmt.Errorf("failed to upload to S3: %w", err)
	}
	defer uploadResp.Body.Close()
	
	logger.Debugf("    ✓ S3 upload response: Status %d %s", uploadResp.StatusCode, uploadResp.Status)
	
	if uploadResp.StatusCode != http.StatusOK && uploadResp.StatusCode != http.StatusNoContent {
		uploadRespBody, _ := io.ReadAll(uploadResp.Body)
		logger.Errorf("    ✗ S3 upload returned error status %d: %s", uploadResp.StatusCode, string(uploadRespBody))
		return "", fmt.Errorf("S3 upload returned status %d", uploadResp.StatusCode)
	}
	
	logger.Infof("    ✓ File uploaded to S3 successfully (Step 2 complete)")
	
	// If we don't have file_id yet, try to get it from storage response after upload
	if fileID == "" {
		// Some APIs return file_id after upload, check if it's in the response
		if id, ok := storageResult["file_id"].(string); ok && id != "" {
			fileID = id
		} else {
			// Use a generated identifier
			fileID = s3Key
			logger.Warnf("    ⚠ No file_id in storage response, using S3 key as identifier")
		}
	}

	// Step 3: Attach file to RAG using file_ids
	// IMPORTANT: This step must complete successfully for the file to be considered processed
	attachURL := fmt.Sprintf("%s/api/v1/rags/%s/files", wonderfulAPIURL, wonderfulRAGID)
	logger.Infof("    Step 3: Attaching uploaded file to RAG: %s", attachURL)
	
	// Create JSON request body with file_ids
	requestBody := map[string]interface{}{
		"file_ids": []string{fileID},
	}
	
	jsonBody, err := json.Marshal(requestBody)
	if err != nil {
		logger.Errorf("    ✗ Failed to marshal JSON: %v", err)
		return "", fmt.Errorf("failed to marshal request: %w", err)
	}
	
	logger.Debugf("    ✓ JSON request body: %s", string(jsonBody))

	// Create attachment request
	attachReq, err := http.NewRequest("POST", attachURL, bytes.NewBuffer(jsonBody))
	if err != nil {
		logger.Errorf("    ✗ Failed to create attachment request: %v", err)
		return "", fmt.Errorf("failed to create attachment request: %w", err)
	}

	attachReq.Header.Set("Content-Type", "application/json")
	attachReq.Header.Set("Authorization", "Bearer "+wonderfulAPIKey)
	logger.Debugf("    ✓ Attachment request created with Content-Type: application/json")

	// Execute attachment request
	attachResp, err := client.Do(attachReq)
	if err != nil {
		logger.Errorf("    ✗ Attachment request failed: %v", err)
		return "", fmt.Errorf("failed to execute attachment request: %w", err)
	}
	defer attachResp.Body.Close()

	logger.Debugf("    ✓ Received attachment response: Status %d %s", attachResp.StatusCode, attachResp.Status)
	
	attachRespBody, err := io.ReadAll(attachResp.Body)
	if err != nil {
		logger.Errorf("    ✗ Failed to read attachment response body: %v", err)
		return "", fmt.Errorf("failed to read attachment response: %w", err)
	}

	if attachResp.StatusCode != http.StatusOK && attachResp.StatusCode != http.StatusCreated {
		errorMsg := string(attachRespBody)
		if attachResp.StatusCode == http.StatusRequestEntityTooLarge {
			logger.Errorf("    ✗ File too large (413 Request Entity Too Large): %s", errorMsg)
			return "", fmt.Errorf("file too large for API (413): file size may exceed server limits")
		}
		logger.Errorf("    ✗ API returned error status %d: %s", attachResp.StatusCode, errorMsg)
		return "", fmt.Errorf("API returned status %d: %s", attachResp.StatusCode, errorMsg)
	}

	logger.Infof("    ✓ File attached to RAG successfully (Step 3 complete)")
	logger.Debugf("    Attachment response: %s", string(attachRespBody))
	
	// Both upload (Step 2) and attach (Step 3) completed successfully
	logger.Infof("    ✓ Complete: File uploaded and attached to RAG (file_id: %s)", fileID)
	
	return fileID, nil
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

func formatFileSize(bytes int64) string {
	const unit = 1024
	if bytes < unit {
		return fmt.Sprintf("%d B", bytes)
	}
	div, exp := int64(unit), 0
	for n := bytes / unit; n >= unit; n /= unit {
		div *= unit
		exp++
	}
	return fmt.Sprintf("%.2f %cB", float64(bytes)/float64(div), "KMGTPE"[exp])
}

