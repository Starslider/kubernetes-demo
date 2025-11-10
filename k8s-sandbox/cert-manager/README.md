# cert-manager Configuration

This directory contains the configuration for cert-manager, which provides automated certificate management in Kubernetes.

**Version**: 1.13.2 (Latest stable)
**GitHub**: [cert-manager/cert-manager](https://github.com/cert-manager/cert-manager)
**Documentation**: [cert-manager Documentation](https://cert-manager.io/docs/)

## Components

- **kustomization.yaml**: Kustomize configuration for deployment
- **letsencrypt-issuer.yaml**: Let's Encrypt certificate issuer configuration
- **values.yaml**: Helm chart values for cert-manager

## Certificate Management

cert-manager is configured to:
- Automatically obtain and renew Let's Encrypt certificates
- Handle certificate lifecycle management
- Provide certificates for cluster services

## Usage

Update certificate configuration by modifying the letsencrypt-issuer.yaml file. Changes are automatically applied by ArgoCD.

For manual application:
```bash
kubectl apply -k .
```