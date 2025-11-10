# AWX Configuration

This directory contains the configuration for AWX, the open source version of Ansible Tower.

## Components

- **httproute-grant.yaml**: Gateway API route configuration for AWX web interface
- **kustomization.yaml**: Kustomize configuration for deployment

## Usage

The AWX deployment is managed by ArgoCD. To make changes:
1. Update the relevant configuration files
2. Commit changes to git
3. ArgoCD will automatically sync the changes

For manual application:
```bash
kubectl apply -k .
```