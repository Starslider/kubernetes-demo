# Building the RAG Pipeline Docker Image

The RAG pipeline uses a pre-built Docker image to significantly reduce startup time by pre-installing dependencies and pre-downloading the embedding model.

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

- **Faster startup**: Dependencies and model are pre-installed
- **More reliable**: No network dependencies during pod startup
- **Better resource usage**: Build once, use many times
- **Automated builds**: GitHub Actions handles building and pushing

The image includes:
- Python 3.11
- All required Python packages (elasticsearch, sentence-transformers, flask, requests)
- Pre-downloaded embedding model (all-MiniLM-L6-v2)

