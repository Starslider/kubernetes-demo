# CyberChef Configuration

This directory contains the configuration for CyberChef, a web app for data analysis and manipulation.

## Components

- **deployment.yaml**: Kubernetes deployment configuration
- **httproute-grant.yaml**: Gateway API route configuration
- **kustomization.yaml**: Kustomize configuration
- **service.yaml**: Service configuration
- **values.yaml**: Configuration values

## Features

The CyberChef deployment provides:
- Web-based data analysis tools
- Gateway API integration
- Configurable resources and scaling

## Usage

To modify the deployment:
1. Update configuration files as needed
2. Let ArgoCD sync the changes or apply manually:
```bash
kubectl apply -k .
```