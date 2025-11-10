# Crossplane Configuration

This directory contains the configuration for Crossplane, a Kubernetes-native infrastructure provisioning tool.

## Components

- **kustomization.yaml**: Kustomize configuration for deployment
- **values.yaml**: Helm chart values for Crossplane

## Features

Crossplane is configured to:
- Manage cloud infrastructure through Kubernetes APIs
- Provision and manage cloud resources
- Enable infrastructure as code

## Usage

Update provider configurations and composite resources through values.yaml. Changes are automatically applied by ArgoCD.

For manual application:
```bash
kubectl apply -k .
```