# External Secrets Configuration

This directory contains the configuration for External Secrets Operator, which manages secrets from external sources.

## Components

- **1password-store.yaml**: 1Password integration configuration
- **kustomization.yaml**: Kustomize configuration
- **test-credentials.yaml**: Test credentials configuration

## Features

External Secrets is configured to:
- Integrate with 1Password as a secrets backend
- Automatically sync secrets to Kubernetes
- Manage secret lifecycle
- Provide secure credentials management

## Usage

Update secret store configuration in 1password-store.yaml. Changes are automatically applied by ArgoCD.

For manual application:
```bash
kubectl apply -k .
```