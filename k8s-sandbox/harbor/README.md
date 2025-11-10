# Harbor Configuration

This directory contains the configuration for Harbor, an enterprise-class container registry.

**Version**: 2.9.1 (Latest stable)
**GitHub**: [goharbor/harbor](https://github.com/goharbor/harbor)
**Documentation**: [Harbor Documentation](https://goharbor.io/docs/)

## Components

- **httproute-grant.yaml**: Gateway API route configuration
- **kustomization.yaml**: Kustomize configuration

## Features

Harbor provides:
- Container image storage and distribution
- Image scanning and signing
- RBAC with external authentication
- Project management and quotas

## Usage

Modify the configuration files and let ArgoCD sync the changes, or apply manually:
```bash
kubectl apply -k .
```