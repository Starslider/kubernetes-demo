# Cilium Configuration

This directory contains the configuration for Cilium, a networking and security solution for Kubernetes.

**Version**: 1.14.4 (Latest stable)
**GitHub**: [cilium/cilium](https://github.com/cilium/cilium)
**Documentation**: [Cilium Documentation](https://docs.cilium.io/en/stable/)

## Components

- **bgpconf.yaml**: BGP configuration for network routing
- **httproute-grant.yaml**: Gateway API route configuration
- **IPAddressPool.yaml**: IP address pool configuration for services
- **kustomization.yaml**: Kustomize configuration for deployment

## Network Configuration

Cilium is configured to provide:
- Container networking
- Network policy enforcement
- Load balancing
- BGP integration for external connectivity

## Usage

Modify the configuration files and let ArgoCD sync the changes, or apply manually:
```bash
kubectl apply -k .
```