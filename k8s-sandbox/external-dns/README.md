# External DNS Configuration

This directory contains the configuration for External DNS, which automates DNS management for Kubernetes services.

**Version**: 0.13.6 (Latest stable)
**GitHub**: [kubernetes-sigs/external-dns](https://github.com/kubernetes-sigs/external-dns)
**Documentation**: [ExternalDNS Documentation](https://kubernetes-sigs.github.io/external-dns/)

## Components

- **cloudflare-apikey.yaml**: Cloudflare API credentials
- **kustomization.yaml**: Kustomize configuration
- **values.yaml**: Helm chart values

## Features

External DNS is configured to:
- Automatically manage DNS records for services
- Integrate with Cloudflare DNS
- Support multiple DNS providers
- Handle DNS record lifecycle

## Usage

Update DNS provider configuration in values.yaml. Changes are automatically applied by ArgoCD.

For manual application:
```bash
kubectl apply -k .
```