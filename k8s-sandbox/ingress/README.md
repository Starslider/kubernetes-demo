# Ingress Configuration

This directory contains the configuration for the Kubernetes ingress system.

## Components

- **cert.yaml**: Certificate configuration
- **kustomization.yaml**: Kustomize configuration
- **ingress/**: Additional ingress configurations

## Features

The ingress configuration provides:
- TLS certificate management
- HTTP/HTTPS routing
- Service exposure
- Load balancing

## Usage

Update ingress rules and certificates as needed. Changes are automatically applied by ArgoCD.

For manual application:
```bash
kubectl apply -k .
```