# UniFi OS Server

This directory contains the configuration and ArgoCD integration for **UniFi OS Server** — the current standard for self-hosting UniFi, replacing the legacy UniFi Network Application.

**Purpose**: Centralized management of UniFi networking gear (switches, access points, etc.) with full UniFi OS features (Organizations, IdP Integration, Site Magic SD-WAN, Site Manager compatibility).

## Why it is here

You bought UniFi 2.5Gb switches. UniFi switches deliver advanced features (VLANs per port, LACP, detailed monitoring, port profiles, firmware management, etc.) **only when managed by a UniFi controller**.

Without a controller they operate in a very limited "standalone" mode.

## Components

- Pure Kustomize manifests based on [lemker/unifi-os-server](https://github.com/lemker/unifi-os-server)
- **Image**: `ghcr.io/lemker/unifi-os-server:v1.3.0`
- LoadBalancer service + external-dns for `unifi.dhlabs.org`
- Privileged deployment (required for UniFi OS systemd services and cgroup access)

## Installation / Sync

The component is deployed as a standard ArgoCD Application (`apps/unifi.yaml`) using a single source pointing to this directory. ArgoCD runs `kubectl kustomize` on it.

## Migration from legacy UniFi Network Application

This replaces the previous `jacobalberty/unifi-docker` deployment. Key differences:

| | Legacy Network App | UniFi OS Server |
|---|---|---|
| Image | `ghcr.io/jacobalberty/unifi-docker` | `ghcr.io/lemker/unifi-os-server` |
| Web UI port | 8443 | **11443** |
| Discovery port | 10001/UDP | **10003/UDP** |
| Inform URL | `https://…:8443/inform` | `http://…:8080/inform` |
| PVC | `unifi-data` (10Gi) | `unifi-os-server-pvc` (32Gi) |
| TLS | Wildcard cert mounted | Self-signed (accept in browser) |

**Data does not migrate automatically.** Back up from the old controller, deploy UniFi OS Server fresh, then restore or re-adopt devices.

## Important Configuration Steps (after first deploy)

The setup is pre-configured to use **unifi.dhlabs.org**.

1. **DNS**:
   - `external-dns.alpha.kubernetes.io/hostname: unifi.dhlabs.org` is already set on the LoadBalancer service.
   - external-dns will automatically create the A record in Cloudflare.

2. **UOS_SYSTEM_IP**:
   - `UOS_SYSTEM_IP` is set to `unifi.dhlabs.org` inside deployment.yaml.
   - Devices will be instructed to connect using the domain name.

3. Deploy / sync via ArgoCD.

4. Verify:
   ```bash
   kubectl -n unifi get svc unifi -o wide
   dig unifi.dhlabs.org
   ```

5. Adopt switches:
   - SSH into device with username/password: `ubnt`/`ubnt`
   - Set inform address: `set-inform http://unifi.dhlabs.org:8080/inform`
   - Or adopt via the UniFi UI once you can reach it.

6. Access the UI:
   - https://unifi.dhlabs.org:11443 (accept the self-signed certificate on first visit)

You can optionally pin a specific LoadBalancer IP by editing the annotations in service.yaml (Cilium lbipam) or adding loadBalancerIP.

## Ports (exposed via LoadBalancer)

- 11443/TCP — Web UI + API
- 8080/TCP — Device and application communication (inform)
- 3478/UDP — STUN (required for adoption and remote management)
- 10003/UDP — Device discovery during adoption

Make sure your Cilium LB / firewall allows these from the switches' subnet.

## Persistence & Backups

- `unifi-os-server-pvc` stores configuration, MongoDB data, and UniFi OS state across multiple subPaths.
- In the UniFi UI (Settings → System → Backups) enable scheduled backups.
- The backups land inside the PVC.

## Monitoring (recommended)

Deploy **Unpoller** (https://unpoller.com) as a separate small deployment/Helm release.
It scrapes the UniFi controller API and exports metrics for your VictoriaMetrics + Grafana stack.

Example dashboards are available on Grafana.com for Unpoller.

## Upgrades

1. Backup first (UI or export the PVC).
2. Update the image tag in deployment.yaml (check [releases](https://github.com/lemker/unifi-os-server/releases)).
3. Let ArgoCD sync.
4. Verify devices are still connected after upgrade.

## References

- lemker/unifi-os-server: https://github.com/lemker/unifi-os-server
- Image: https://github.com/lemker/unifi-os-server/pkgs/container/unifi-os-server
- Self-hosting guide: https://help.ui.com/hc/en-us/articles/34210126298775-Self-Hosting-UniFi

## Notes specific to this homelab

- Uses your Cilium BGP LoadBalancer for a stable IP.
- Exposed directly via LoadBalancer (not through the shared HTTPS Gateway).
- Privileged container required — UniFi OS runs components as systemd services needing host cgroup access.
- Namespace: `unifi`