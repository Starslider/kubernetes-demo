# UniFi OS Server

This directory contains the configuration and ArgoCD integration for **UniFi OS Server** — the current standard for self-hosting UniFi, replacing the legacy UniFi Network Application.

**Purpose**: Centralized management of UniFi networking gear (switches, access points, etc.) with full UniFi OS features (Organizations, IdP Integration, Site Magic SD-WAN, Site Manager compatibility).

## Components

- Pure Kustomize manifests based on [lemker/unifi-os-server](https://github.com/lemker/unifi-os-server)
- **Image**: `ghcr.io/lemker/unifi-os-server:v1.3.0`
- A unified LoadBalancer service exposes the web UI, inform, STUN, and discovery ports
- `external-dns` publishes `unifi.dhlabs.org` for the LoadBalancer
- The dedicated `unifi-tls` Let's Encrypt certificate is mounted into UniFi OS Server
- Privileged deployment with systemd-related temporary filesystems
- Persistent data in the NFS-backed `unifi-os-server-pvc`

## Installation / Sync

Deployed via `apps/unifi.yaml` in the `unifi` namespace.

DNS for `unifi.dhlabs.org` is managed by `external-dns` and points directly to the LoadBalancer.

## After first deploy

1. Sync the `unifi` app in ArgoCD.
2. First boot takes several minutes while PostgreSQL and UniFi OS services start.
3. Open **https://unifi.dhlabs.org**.
4. Adopt devices:
   - For a new switch, or a device that is pending adoption but reports "cannot reach",
     start with the direct LoadBalancer IP over HTTP:
     ```text
     set-inform http://192.168.1.213:8080/inform
     ```
     This isolates DNS, certificate, and return-path issues during initial provisioning.
   - Once the device is adopted and connected, switch to the stable hostname:
     ```text
     set-inform http://unifi.dhlabs.org:8080/inform
     ```
   - Apply the command through the UniFi mobile app, the web UI, or SSH on the device.

## Ports (via LoadBalancer at 192.168.1.213)

| Port | Protocol | Purpose |
|------|----------|---------|
| 443 | TCP | Web UI + API |
| 8080 | TCP | Device inform / communication |
| 3478 | UDP | STUN |
| 10003 | UDP | Device discovery |

Additional upstream services (RTP, hotspot, syslog, etc.) are defined as ClusterIP services but are not exposed through the LoadBalancer by default.

## Troubleshooting adoption

- A device showing as pending has reached the controller at least once.
- If adoption fails, use `set-inform http://192.168.1.213:8080/inform` to bypass DNS and TLS while testing.
- Confirm the device can reach the LoadBalancer on TCP port 8080.
- Check controller logs with `kubectl -n unifi logs deploy/unifi-os-server`.
- The UniFi mobile app is often the easiest way to configure a first device because it has direct LAN access.
- After adoption succeeds, use `set-inform http://unifi.dhlabs.org:8080/inform` for the stable hostname.

## References

- lemker/unifi-os-server: https://github.com/lemker/unifi-os-server
- Upstream Kubernetes manifests: https://github.com/lemker/unifi-os-server/tree/main/kubernetes
