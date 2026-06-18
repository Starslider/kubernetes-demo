# UniFi Network Controller

This directory contains the configuration and ArgoCD integration for the **UniFi Network Application** (controller).

**Purpose**: Centralized management of UniFi networking gear (switches, access points, etc.).

## Why it is here

You bought UniFi 2.5Gb switches. UniFi switches deliver advanced features (VLANs per port, LACP, detailed monitoring, port profiles, firmware management, etc.) **only when managed by a UniFi controller**.

Without a controller they operate in a very limited "standalone" mode.

## Components

- **Upstream**: [mkilchhofer/unifi](https://artifacthub.io/packages/helm/unifi/unifi) (fork of the popular k8s-at-home chart)
- **Image**: `jacobalberty/unifi` (well-maintained community packaging of the official UniFi Network Application)
- Local values + Gateway API exposure via your existing ingress gateway

## Installation / Sync

The component is deployed as an ArgoCD Application (`apps/unifi.yaml`).

It uses the standard multi-source pattern:
- Upstream Helm chart (OCI)
- Local overlay (`values.yaml` + `httproute-grant.yaml`)

## Important Configuration Steps (after first deploy)

The setup is pre-configured to use **unifi.dhlabs.org**.

1. **DNS**:
   - `external-dns.alpha.kubernetes.io/hostname: unifi.dhlabs.org` is already set on the LoadBalancer service.
   - external-dns will automatically create the A record in Cloudflare.

2. **SYSTEM_IP**:
   - Already set to `unifi.dhlabs.org` in `values.yaml`.
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

You can optionally pin a specific LoadBalancer IP by adding a `lbipam.cilium.io/ips` annotation in `values.yaml`.

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
2. Update `targetRevision` in `apps/unifi.yaml` and/or image tag in `values.yaml`.
3. Let ArgoCD sync.
4. Verify devices are still connected after upgrade.

## References

- jacobalberty/unifi-docker: https://github.com/jacobalberty/unifi-docker
- Chart: https://github.com/mkilchhofer/unifi-chart
- UniFi Network Application releases: https://ui.com/download/releases/network-server

## Notes specific to this homelab

- Uses your Cilium BGP LoadBalancer for a stable IP.
- Exposed using the same Gateway API + HTTPRoute + ReferenceGrant pattern as other apps.
- Namespace: `unifi`
- Follows the exact multi-source + kustomize + apps directory convention used by minio, authentik, cyberchef, etc.
