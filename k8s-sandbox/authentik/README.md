# Authentik Configuration

This directory contains the configuration for Authentik, an identity provider and access management solution.

**Version**: 2023.10.5 (Latest stable)
**GitHub**: [goauthentik/authentik](https://github.com/goauthentik/authentik)
**Documentation**: [Authentik Documentation](https://goauthentik.io/docs/)

## Components

- **httproute-grant.yaml**: Gateway API route configuration for Authentik
- **kustomization.yaml**: Kustomize configuration for deployment
- **values.yaml**: Helm chart values configuration

## Configuration

The Authentik deployment is configured to provide:
- Single Sign-On (SSO) for cluster services
- User authentication and authorization
- Access management policies

## Usage

Apply changes by updating the values.yaml file and letting ArgoCD sync the changes, or manually apply with:

```bash
kubectl apply -k .
```