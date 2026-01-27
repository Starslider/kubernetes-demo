# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a comprehensive home lab Kubernetes repository demonstrating production-ready GitOps patterns. It supports multiple Linux distributions (Arch Linux, Flatcar, Ubuntu) across VMs, bare metal, and hybrid setups using Kubernetes v1.34 with containerd runtime.

**Key Architectural Principles:**
- GitOps-first: All deployments managed via ArgoCD
- Hybrid Helm strategy: Upstream Helm charts + local Kustomize overlays
- Multi-source ArgoCD applications for flexibility
- Modern networking via Gateway API and Cilium with BGP
- Enterprise patterns in home lab: cert-manager, external secrets, HA databases

## Commands

### Validation and Testing

```bash
# Validate all Kubernetes manifests (kustomize + yamllint + kubeconform)
./scripts/check-yaml.sh

# Manually validate a specific component
kubectl kustomize k8s-sandbox/component-name | kubeconform -strict -verbose

# Lint YAML files
yamllint k8s-sandbox/component-name/
```

### ArgoCD Operations

```bash
# Sync specific application
kubectl -n argocd argocd app sync app-name

# Check application status
kubectl -n argocd get applications

# View sync status of all apps
kubectl -n argocd argocd app list

# Force refresh application
kubectl -n argocd argocd app get app-name --refresh
```

### Cilium Networking

```bash
# Check Cilium status
kubectl -n kube-system exec -ti ds/cilium -- cilium status

# Verify BGP configuration
kubectl get bgpconfigurations -n kube-system

# Check LoadBalancer IP pools
kubectl get ipaddresspools -n kube-system

# Test pod connectivity
kubectl -n kube-system exec -ti ds/cilium -- cilium connectivity test
```

### Monitoring and Observability

```bash
# Check VictoriaMetrics components
kubectl -n monitoring get pods

# Access Grafana (port-forward if needed)
kubectl -n monitoring port-forward svc/grafana 3000:80

# View ServiceMonitors
kubectl get servicemonitors -A

# Check alerts
kubectl -n monitoring logs deployment/vmalertmanager
```

### PostgreSQL (CloudNativePG)

```bash
# Check PostgreSQL cluster status
kubectl -n postgres get clusters

# View backup status
kubectl -n postgres get backups

# Connect to primary instance
kubectl -n postgres cnpg psql cluster-name

# Check replication status
kubectl -n postgres get pods -l cnpg.io/instanceRole=primary
```

### Secret Management

```bash
# Verify External Secrets operator
kubectl -n external-secrets-system get pods

# Check SecretStore status
kubectl get secretstores -A

# View synced ExternalSecrets
kubectl get externalsecrets -A

# Debug secret sync issues
kubectl describe externalsecret secret-name -n namespace
```

### Certificate Management

```bash
# Check certificate status
kubectl get certificates -A

# View ClusterIssuers
kubectl get clusterissuers

# Debug certificate issues
kubectl describe certificate cert-name -n namespace

# Check cert-manager logs
kubectl -n cert-manager logs deployment/cert-manager
```

## Architecture and Structure

### Directory Organization

- `k8s-sandbox/` - Primary Kubernetes configurations (22+ components)
  - `apps/` - **Central location for all 28 ArgoCD Application definitions**
  - `argocd/` - ArgoCD server configuration and customizations
  - `cilium/` - CNI with BGP configs
  - `monitoring/` - VictoriaMetrics, Grafana, AlertManager stack
  - `authentik/` - SSO and identity management
  - `cert-manager/` - TLS automation with Let's Encrypt
  - `external-secrets/` - 1Password integration
  - `external-dns/` - Automated DNS management
  - `ingress/` - Gateway API and HTTPRoutes
  - `postgres/` - CloudNativePG HA database
  - `harbor/`, `minio/`, `awx/`, `home-assistant/`, etc. - Application components

- `flatcar/` - Flatcar Linux specific installation guides
- `scripts/` - Validation and utility scripts
- `.github/workflows/` - CI/CD for container image builds

### Manifest Patterns

**Kustomize-First Approach:**
- Each component directory contains `kustomization.yaml`
- Use Kustomize for local customizations and overlays
- 27+ kustomization files throughout the repository

**Multi-Source ArgoCD Pattern:**
```yaml
sources:
  - repoURL: https://charts.external-package.io  # Upstream Helm chart
    chart: package-name
    targetRevision: 1.2.3
  - repoURL: https://github.com/Starslider/kubernetes-demo.git  # Local configs
    path: k8s-sandbox/component
    targetRevision: HEAD
```

**Components using Multi-Source:**
- cert-manager (Jetstack Helm + local issuers)
- cilium (Cilium Helm + BGP configs)
- external-secrets (Operator Helm + SecretStores)
- monitoring (VictoriaMetrics Helm + dashboards)
- authentik (Goauthentik Helm + custom configs)

### Common Configuration Patterns

**Gateway API (Modern Ingress):**
- Gateway defined in `k8s-sandbox/ingress/ingress/`
- HTTPRoute manifests in component directories (e.g., `argocd-httproute.yaml`)
- Cross-namespace routing via HTTPRouteGrant CRDs

**External Secrets Integration:**
- SecretStore defined in `k8s-sandbox/external-secrets/`
- ExternalSecret manifests in component directories (e.g., `authentik-external-secret.yaml`)
- Syncs from 1Password to Kubernetes Secrets automatically

**TLS Automation:**
- ClusterIssuer defined in `k8s-sandbox/cert-manager/letsencrypt-issuer.yaml`
- Certificate objects referenced by HTTPRoutes for TLS termination
- Automatic renewal handled by cert-manager

**Sync Wave Ordering:**
- Use `argocd.argoproj.io/sync-wave: "N"` annotation for dependency ordering
- Example: PostgreSQL cluster (wave 1) → PgBouncer pooler (wave 2)

**Ignore Drift for Managed Resources:**
- Use `ignoreDifferences` in ArgoCD Applications for operator-managed fields
- Common for Cilium ConfigMaps, PostgreSQL cluster status, webhook configs

### Network Architecture

**Cilium CNI Features:**
- BGP advertisement for LoadBalancer services (`k8s-sandbox/cilium/bgpconf.yaml`)
- IP address pools defined in `IPAddressPool.yaml`
- Layer 2 announcements for home network integration

**Service Exposure:**
- Gateway API HTTPRoutes (preferred)
- LoadBalancer services with Cilium BGP (for external access)
- ClusterIP services (internal only)

### Monitoring Stack

**Components:**
- VictoriaMetrics (metrics storage)
- Grafana (dashboards and visualization)
- VMAgent (metrics collection)
- AlertManager (alert routing to Discord)
- Promtail + Loki (log aggregation)

**Monitoring Patterns:**
- ServiceMonitor CRs for Prometheus-compatible endpoints
- PodMonitor for pod-level metrics (used by CloudNativePG)
- Intentional suppression of TLS warnings on control-plane components

### PostgreSQL HA Pattern

**CloudNativePG Operator:**
- Primary instance (read-write)
- Streaming replicas (read-only, load balanced)
- PgBouncer pooler (connection pooling)
- Automatic failover and backup management

**Generated Services:**
- `cluster-name-rw` (primary only)
- `cluster-name-ro` (replicas)
- `cluster-name-pooler` (connection pooler)

## Development Workflow

### Adding New Applications

1. Create component directory in `k8s-sandbox/new-component/`
2. Add `kustomization.yaml` with resources
3. Create ArgoCD Application manifest in `k8s-sandbox/apps/new-component.yaml`
4. For Helm charts, use multi-source pattern with local `values.yaml`
5. Add HTTPRoute if external access needed
6. Add ExternalSecret if secrets required
7. Run `./scripts/check-yaml.sh` to validate
8. Commit and let ArgoCD sync

### Modifying Existing Components

1. Make changes to component directory in `k8s-sandbox/component-name/`
2. Validate with `kubectl kustomize k8s-sandbox/component-name/`
3. Run `./scripts/check-yaml.sh` for full validation
4. Commit changes (ArgoCD auto-sync or manual sync depending on app config)

### Working with Secrets

- Never commit secrets directly to git
- Use ExternalSecret CRs pointing to 1Password
- Define ExternalSecret in component directory
- Secret synced automatically by External Secrets Operator

### Debugging ArgoCD Sync Issues

1. Check Application status: `kubectl -n argocd get application app-name -o yaml`
2. Look for `status.conditions` and `status.health`
3. Check sync logs: `kubectl -n argocd argocd app logs app-name`
4. For multi-source apps, verify both sources are accessible
5. Check for ignoreDifferences preventing sync

## Important Notes

### Commit Message Convention
Follow Conventional Commits format:
- `feat(component): description` - New features
- `fix(component): description` - Bug fixes
- `docs: description` - Documentation changes
- `chore(component): description` - Maintenance tasks

### ArgoCD Sync Policies
- Some apps have `automated: enabled: true` (e.g., monitoring)
- Most require manual sync for safety
- Use sync waves for dependency ordering

### Security Considerations
- TLS certificates managed by cert-manager (Let's Encrypt)
- Secrets synced from 1Password (never in git)
- NetworkPolicies controlled by Cilium
- SSO via Authentik for supported applications

### Cilium BGP Configuration
When modifying BGP configs or IP pools:
1. Edit `k8s-sandbox/cilium/bgpconf.yaml` or `IPAddressPool.yaml`
2. Validate changes won't conflict with existing network
3. Restart Cilium pods if needed: `kubectl -n kube-system rollout restart ds/cilium`

### Multi-Distribution Support
- Main setup guide focuses on Arch Linux VMs (`k8s-sandbox/README.md`)
- Flatcar Linux guide in `flatcar/README.md`
- Ubuntu and other distros: follow generic kubeadm setup from main guide

### CI/CD Workflows
- Container image builds triggered by path changes
- Images pushed to GitHub Container Registry (ghcr.io)
- Tagging: `latest` + `branch-sha` tags
- Located in `.github/workflows/`
