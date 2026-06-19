# UniFi OS Server

This directory contains the configuration and ArgoCD integration for **UniFi OS Server** — the current standard for self-hosting UniFi, replacing the legacy UniFi Network Application.

**Purpose**: Centralized management of UniFi networking gear (switches, access points, etc.) with full UniFi OS features (Organizations, IdP Integration, Site Magic SD-WAN, Site Manager compatibility).

## Components

- Pure Kustomize manifests based on [lemker/unifi-os-server](https://github.com/lemker/unifi-os-server)
- **Image**: `ghcr.io/lemker/unifi-os-server:v1.3.0`
- Upstream ClusterIP [services](https://github.com/lemker/unifi-os-server/blob/main/kubernetes/service.yaml)
- Exposed via the shared Cilium Gateway (`k8s-sandbox/ingress`):
  - **HTTPRoute**: `https://unifi.dhlabs.org` → `unifi-os-server-webui-svc:80` (TLS terminated by gateway with `dhlabs-wildcard`)
  - **TCPRoute**: port `8080` → device/application communication (inform)
  - **UDPRoute**: port `3478` (STUN), port `10003` (discovery)
- Privileged deployment with host cgroup mount (required for UniFi OS systemd services)
- Local data on `hostPath` at `/srv/unifi-os-server` on `arch-kubernetes-node0` (MongoDB does not run reliably on NFS)

## Installation / Sync

Deployed via two ArgoCD Applications:

- `apps/unifi.yaml` — deployment + services in `unifi` namespace
- `apps/ingress.yaml` — HTTP/TCP/UDP routes in `ingress` namespace

DNS for `unifi.dhlabs.org` is handled by the gateway wildcard (`*.dhlabs.org` → `192.168.1.210`).

## After first deploy

1. Sync both `unifi` and `ingress` apps in ArgoCD.
2. First boot takes several minutes while PostgreSQL and UniFi OS services start.
3. Open **https://unifi.dhlabs.org** and accept the UniFi self-signed certificate (TLS passthrough).
4. Adopt devices: `set-inform http://unifi.dhlabs.org:8080/inform`

## Ports (via ingress gateway at 192.168.1.210)

| Port | Protocol | Purpose |
|------|----------|---------|
| 443 | TCP | Web UI + API (TLS passthrough) |
| 8080 | TCP | Device inform / communication |
| 3478 | UDP | STUN |
| 10003 | UDP | Device discovery |

Additional upstream services (RTP, hotspot, syslog, etc.) are defined but not routed through the gateway by default. Add TCP/UDP listeners and routes in `k8s-sandbox/ingress/ingress/` if needed.

## References

- lemker/unifi-os-server: https://github.com/lemker/unifi-os-server
- Upstream Kubernetes manifests: https://github.com/lemker/unifi-os-server/tree/main/kubernetes