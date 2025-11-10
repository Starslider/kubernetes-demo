# MinIO Configuration

This directory contains the configuration for MinIO, an S3-compatible object storage system.

**Version**: RELEASE.2023-10-07T15-07-38Z (Latest stable)
**GitHub**: [minio/minio](https://github.com/minio/minio)
**Documentation**: [MinIO Documentation](https://min.io/docs/minio/kubernetes/upstream/)

## Features

MinIO provides:
- S3-compatible object storage
- Multi-tenant support
- High availability
- Bucket management
- Access control

## Usage

Update storage configuration and access policies as needed. Changes are automatically applied by ArgoCD.

For manual application:
```bash
kubectl apply -k .
```