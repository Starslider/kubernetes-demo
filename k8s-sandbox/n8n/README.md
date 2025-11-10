# n8n Configuration

This directory contains the configuration for n8n, a workflow automation tool.

**Version**: 1.14.2 (Latest stable)
**GitHub**: [n8n-io/n8n](https://github.com/n8n-io/n8n)
**Documentation**: [n8n Documentation](https://docs.n8n.io/)

## Features

n8n provides:
- Workflow automation
- API integrations
- Custom workflow nodes
- Webhooks and triggers

## Usage

Update workflow configurations and credentials as needed. Changes are automatically applied by ArgoCD.

For manual application:
```bash
kubectl apply -k .
```