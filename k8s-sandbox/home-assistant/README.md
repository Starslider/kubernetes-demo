# Home Assistant Configuration

This directory contains the configuration for Home Assistant, a home automation platform.

**Version**: 2023.10.5 (Latest stable)
**GitHub**: [home-assistant/core](https://github.com/home-assistant/core)
**Documentation**: [Home Assistant Documentation](https://www.home-assistant.io/docs/)

## Components

- **clusterrole.yaml**: Cluster-wide role configuration
- **clusterrolebinding.yaml**: Role binding configuration
- **kustomization.yaml**: Kustomize configuration
- **serviceaccount.yaml**: Service account configuration
- **serviceaccount-token-secret.yaml**: Service account token configuration

## Features

Home Assistant deployment includes:
- Kubernetes integration
- RBAC configuration
- Service account management
- Cluster access control

## Usage

To modify the deployment:
1. Update the relevant configuration files
2. Let ArgoCD sync the changes or apply manually:
```bash
kubectl apply -k .
```