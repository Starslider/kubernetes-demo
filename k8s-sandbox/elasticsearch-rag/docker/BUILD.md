# Building the RAG Pipeline Docker Image

The RAG pipeline is implemented in Go for maximum performance and efficiency. The pre-built Docker image significantly reduces startup time.

## Automatic Builds (GitHub Actions)

The Docker image is automatically built and pushed to GitHub Container Registry (GHCR) when changes are made to the `k8s-sandbox/elasticsearch-rag/` directory.

**Image location**: `ghcr.io/starslider/kubernetes-demo/rag-pipeline:latest`

The GitHub Actions workflow (`.github/workflows/build-rag-pipeline.yml`) will:
- Build the image on every push to main branch
- Build (but not push) on pull requests
- Push to GHCR with appropriate tags
- Use build caching for faster builds

## Manual Build

If you need to build locally:

```bash
cd k8s-sandbox/elasticsearch-rag/docker
docker build -t rag-pipeline:latest .
```

See `README-GO.md` for more details on the Go implementation.

## Push to Registry (if needed)

If you're using a different container registry:

```bash
# Tag for your registry
docker tag rag-pipeline:latest your-registry/rag-pipeline:latest

# Push
docker push your-registry/rag-pipeline:latest
```

## Update Deployment

The deployment is configured to use the GHCR image. If using a different registry, update the image in `rag-pipeline-deployment.yaml`:

```yaml
image: your-registry/rag-pipeline:latest
```

## Benefits

- **Ultra-fast startup**: < 1 second (vs 5+ minutes for Python)
- **Small image size**: ~20-50MB (vs ~500MB+ for Python)
- **Low memory usage**: ~50-70% lower than Python
- **Better concurrency**: Native Go goroutines for handling requests
- **Automated builds**: GitHub Actions handles building and pushing

The image includes:
- Go 1.21 compiled binary
- Elasticsearch Go client
- Gin web framework
- Minimal Alpine Linux base image

