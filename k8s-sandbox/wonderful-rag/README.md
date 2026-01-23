# Wonderful RAG S3 Sync

A Kubernetes deployment that automatically syncs files from an AWS S3 bucket to the Wonderful AI Platform API.

## Architecture

```
┌─────────────────┐
│   AWS S3        │
│   Bucket        │
└────────┬────────┘
         │
         │ Download Files
         │
┌────────▼────────┐
│  Sync Service   │
│  (Go Container) │
└────────┬────────┘
         │
         │ Upload Files
         │
┌────────▼──────────────────┐
│  Wonderful AI Platform    │
│  API                      │
└───────────────────────────┘
```

## Components

### Sync Service
- **Type**: Deployment
- **Image**: `ghcr.io/starslider/kubernetes-demo/wonderful-rag:latest`
- **Language**: Go
- **Features**:
  - Automatic S3 bucket monitoring
  - File download and upload to Wonderful API
  - Tracks processed files to avoid duplicates
  - Configurable sync interval
  - REST API for manual triggers and stats

## Configuration

### Environment Variables

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `AWS_REGION` | AWS region for S3 | Yes | `us-east-1` |
| `S3_BUCKET` | S3 bucket name | Yes | - |
| `S3_PREFIX` | S3 prefix/folder path | No | - |
| `AWS_ACCESS_KEY_ID` | AWS access key (or use IAM role) | No* | - |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key (or use IAM role) | No* | - |
| `WONDERFUL_API_URL` | Wonderful API base URL | Yes | `https://swiss-german.app.sb.wonderful.ai` |
| `WONDERFUL_RAG_ID` | RAG ID for file uploads | Yes | - |
| `WONDERFUL_API_KEY` | Wonderful API key | Yes | - |
| `SYNC_INTERVAL_MINUTES` | Sync interval in minutes | No | `30` |
| `PORT` | HTTP server port | No | `8080` |

*AWS credentials are optional if using IAM roles for service accounts (IRSA) in EKS.

### ConfigMap

Edit `configmap.yaml` to configure:
- AWS region
- S3 bucket name
- S3 prefix (optional folder path)
- Wonderful API URL
- Sync interval

### Secrets

1. Copy the example secrets file:
```bash
cp secrets.yaml.example secrets.yaml
```

2. Edit `secrets.yaml` with your actual values:
```yaml
stringData:
  aws_access_key_id: "your-aws-access-key-id"
  aws_secret_access_key: "your-aws-secret-access-key"
  wonderful_rag_id: "your-rag-id"
  wonderful_api_key: "your-api-key"
```

3. Create the secret:
```bash
kubectl apply -f secrets.yaml
```

## API Endpoints

### Health Check
```
GET /health
```

### Trigger Manual Sync
```
POST /api/v1/sync
```

### Get Statistics
```
GET /api/v1/stats
```

### Get Processed Files
```
GET /api/v1/processed-files
```

## Deployment

### Using kubectl
```bash
# Create secret first
kubectl apply -f secrets.yaml

# Deploy application
kubectl apply -k k8s-sandbox/wonderful-rag/
```

### Using ArgoCD
The application is configured in `apps/wonderful-rag.yaml` and will be automatically deployed by ArgoCD.

## How It Works

1. **Initial Sync**: On startup, the service immediately performs a sync
2. **Scheduled Sync**: Then syncs at regular intervals (configurable, default 30 minutes)
3. **File Processing**:
   - Lists all files in the S3 bucket (with optional prefix filter)
   - Downloads each file from S3
   - Uploads to Wonderful API with metadata
   - Tracks processed files to avoid duplicates
   - Logs success/failure for each file

## File Upload Format

Files are uploaded to the Wonderful API endpoint:
```
POST https://swiss-german.app.sb.wonderful.ai/api/v1/rags/{rag_id}/files
```

Files are uploaded as multipart/form-data with:
- **file**: The file content
- **source**: "s3"
- **s3_key**: S3 object key
- **s3_bucket**: S3 bucket name

## AWS IAM Permissions

If using IAM roles for service accounts, the service account needs:
- `s3:ListBucket` on the bucket
- `s3:GetObject` on bucket objects

## Troubleshooting

### Service won't start
- Check all required environment variables are set
- Verify secrets are correctly created in Kubernetes
- Check pod logs: `kubectl logs -n wonderful-rag deployment/wonderful-rag`

### Files not syncing
- Verify S3 bucket name and prefix are correct
- Check AWS credentials or IAM role permissions
- Verify Wonderful API credentials
- Check logs for specific error messages

### Upload failures
- Verify Wonderful API URL is correct
- Check API key is valid
- Verify network connectivity from cluster to API
- Check API response in logs

### View logs
```bash
# View all logs
kubectl logs -f -n wonderful-rag deployment/wonderful-rag

# View logs from specific pod
kubectl logs -f -n wonderful-rag <pod-name>

# View logs from last 100 lines
kubectl logs --tail=100 -n wonderful-rag deployment/wonderful-rag
```

## Development

### Project Structure

```
wonderful-rag/
├── docker/                    # Docker build files
│   ├── Dockerfile            # Container image definition
│   ├── main.go               # Application code
│   ├── go.mod                # Go module definition
│   └── .dockerignore         # Docker ignore rules
├── *.yaml                    # Kubernetes manifests
├── kustomization.yaml        # Kustomize configuration
└── README.md                 # This file
```

### Building the Docker Image

The Docker image is automatically built and pushed to GitHub Container Registry (GHCR) via GitHub Actions when changes are made.

**Pre-built image**: `ghcr.io/starslider/kubernetes-demo/wonderful-rag:latest`

For manual builds:
```bash
cd k8s-sandbox/wonderful-rag/docker
docker build -t wonderful-rag:latest .
```

## Security Best Practices

1. **Secrets Management**: Use Kubernetes secrets or External Secrets Operator
2. **IAM Roles**: Prefer IAM roles for service accounts over access keys
3. **Network Policies**: Restrict network access to only required endpoints
4. **RBAC**: Use least-privilege service accounts
5. **TLS**: Use TLS for all external API calls
6. **Rotate Secrets**: Regularly rotate API keys and AWS credentials

