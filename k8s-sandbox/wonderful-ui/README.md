# Wonderful UI

This folder contains the configuration for deploying the Wonderful UI service.

## Overview

Wonderful UI is the frontend application for the Wonderful Platform - a platform for building and deploying voice agents.

## Helm Chart

The Helm chart is sourced from the main Wonderful repository at:
`deploy/helm-charts/wonderful-ui`

## Configuration

Local values are defined in `values.yaml`. Key configurations:

- **replicaCount**: Number of replicas (default: 1 for demo)
- **resources**: CPU/memory requests and limits
- **ingress**: Ingress configuration (disabled by default)
- **hpa**: Horizontal Pod Autoscaler (disabled for demo)

## Connecting

Once deployed, the service is available at:
```
wonderful-ui.wonderful-ui.svc.cluster.local:80
```

To access locally:
```bash
kubectl port-forward svc/wonderful-ui -n wonderful-ui 3000:80
```

Then open http://localhost:3000

## Notes

- This deployment uses development settings
- HPA is disabled for demo purposes
- Datadog integration is disabled
- No ingress hosts configured - use port-forward for access
