# UniFi Network Controller

This directory contains the configuration and ArgoCD integration for the **UniFi Network Application** (controller).

**Purpose**: Centralized management of UniFi networking gear (switches, access points, etc.).

## Why it is here

You bought UniFi 2.5Gb switches. UniFi switches deliver advanced features (VLANs per port, LACP, detailed monitoring, port profiles, firmware management, etc.) **only when managed by a UniFi controller**.

Without a controller they operate in a very limited "standalone" mode.

## Components

- Pure Kustomize manifests (no upstream Helm to avoid OCI auth/403 issues in ArgoCD)
- **Image**: `ghcr.io/jacobalberty/unifi-docker:latest`
- Gateway API + external-dns for `unifi.dhlabs.org`

## Installation / Sync

The component is deployed as a standard ArgoCD Application (`apps/unifi.yaml`) using a single source pointing to this directory. ArgoCD runs `kubectl kustomize` on it.

## Important Configuration Steps (after first deploy)

The setup is pre-configured to use **unifi.dhlabs.org**.

1. **DNS**:
   - `external-dns.alpha.kubernetes.io/hostname: unifi.dhlabs.org` is already set on the LoadBalancer service.
   - external-dns will automatically create the A record in Cloudflare.

2. **SYSTEM_IP**:
   - SYSTEM_IP is set to `unifi.dhlabs.org` inside deployment.yaml.
   - Devices will be instructed to connect using the domain name.

3. Deploy / sync via ArgoCD.

4. Verify:
   ```bash
   kubectl -n unifi get svc unifi -o wide
   dig unifi.dhlabs.org
   ```

5. Adopt switches:
   - Recommended: `set-inform https://unifi.dhlabs.org:8443/inform`
   - Or via the UniFi UI once you can reach it.

6. Access the UI:
   - Best experience: https://unifi.dhlabs.org (Gateway + wildcard Let's Encrypt cert)
   - Direct: https://unifi.dhlabs.org:8443

You can optionally pin a specific LoadBalancer IP by editing the annotations in service.yaml (Cilium lbipam) or adding loadBalancerIP.

## Ports (exposed via LoadBalancer)

- 8080/TCP — Device Inform
- 8443/TCP — Web UI + HTTPS Inform
- 3478/UDP — STUN (recommended)
- 10001/UDP — Discovery (recommended for easy adoption)

Make sure your Cilium LB / firewall allows these from the switches' subnet.

## Persistence & Backups

- `config` PVC stores configuration + embedded MongoDB data.
- In the UniFi UI (Settings → System → Backups) enable scheduled backups.
- The backups land inside the PVC.

## Monitoring (recommended)

Deploy **Unpoller** (https://unpoller.com) as a separate small deployment/Helm release.
It scrapes the UniFi controller API and exports metrics for your VictoriaMetrics + Grafana stack.

Example dashboards are available on Grafana.com for Unpoller.

## Upgrades

1. Backup first (UI or export the PVC).
2. Update the image tag in deployment.yaml and/or `targetRevision` in `apps/unifi.yaml`.
3. Let ArgoCD sync.
4. Verify devices are still connected after upgrade.

## References

- jacobalberty/unifi-docker: https://github.com/jacobalberty/unifi-docker
- Image: https://github.com/jacobalberty/unifi-docker
- UniFi Network Application releases: https://ui.com/download/releases/network-server

## Notes specific to this homelab

- Uses your Cilium BGP LoadBalancer for a stable IP.
- Exposed using the same Gateway API + HTTPRoute + ReferenceGrant pattern as other apps.
- Namespace: `unifi`
- Follows the exact multi-source + kustomize + apps directory convention used by minio, authentik, cyberchef, etc.
