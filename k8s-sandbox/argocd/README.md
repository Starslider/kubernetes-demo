# ArgoCD Configuration

This directory contains the core ArgoCD configuration files for managing GitOps deployments in the cluster.

**Version**: 2.9.3 (Latest stable)
**GitHub**: [argoproj/argo-cd](https://github.com/argoproj/argo-cd)
**Documentation**: [ArgoCD Documentation](https://argo-cd.readthedocs.io/en/stable/)

## Components

- **app-controller.yaml**: Configuration for the ArgoCD application controller
- **apps.yaml**: Application definitions
- **argocd-cm.yaml**: ArgoCD ConfigMap with general settings
- **argocd-cmd-params-cm.yaml**: Command line parameters configuration
- **argocd-notifications-cm.yaml**: Notification service configuration
- **argocd-rbac-cm.yaml**: Role-based access control settings
- **httproute-grant.yaml**: Gateway API route configuration
- **kustomization.yaml**: Kustomize configuration
- **repo-server.yaml**: Repository server configuration

## Monitoring

The `monitoring` subdirectory contains configuration for ArgoCD monitoring integration.

## Usage

ArgoCD is configured to manage all applications in the `k8s-sandbox/apps` directory. Changes to the configuration should be made through pull requests to ensure proper versioning and review.