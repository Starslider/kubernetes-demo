# Applications Directory

This directory contains Kubernetes manifests for various applications deployed in the cluster.

## Available Applications

- **1password**: 1Password secrets management integration
- **argocd**: Declarative continuous delivery tool
- **authentik**: Identity management solution
- **awx**: Ansible automation platform
- **cert-manager**: Certificate management controller
- **cilium**: Network plugin for container network security
- **crossplane**: Cloud service provisioning and management
- **cyberchef**: Data analysis web app
- **dayz**: DayZ game server
- **external-dns**: DNS management for services
- **external-secrets**: Secrets management from external sources
- **gateway-api**: Gateway API implementation
- **harbor**: Container registry
- **home-assistant**: Home automation platform
- **ingress**: Ingress controller configuration
- **loki**: Log aggregation system
- **metrics-server**: Cluster resource metrics
- **minio**: S3-compatible object storage
- **monitoring**: Monitoring stack configuration
- **n8n**: Workflow automation tool
- **promtail**: Log collector for Loki

## Usage

Applications are deployed via kustomization as defined in `kustomization.yaml`. Each application has its own configuration file and can be individually managed through ArgoCD or kubectl.