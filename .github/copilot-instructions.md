````instructions
# Copilot instructions — kubernetes-demo (concise)
Summary
- This repo is a GitOps-focused Kubernetes sandbox: bootstrapping steps and node-level config live in `k8s-sandbox/README.md` (an Arch Linux + kubeadm tutorial). Workloads and GitOps manifests live under `k8s-sandbox/` and are managed by ArgoCD.
What to know first
- Cluster is bootstrapped with `kubeadm` and uses `containerd` (systemd cgroups). See `k8s-sandbox/README.md` for installation steps (containerd config, pause image, kubeadm init/join examples).
- ArgoCD is the canonical actuator: `k8s-sandbox/argocd/` contains ArgoCD config and `k8s-sandbox/apps/` exposes per-application kustomize entries (see `k8s-sandbox/apps/argocd.yaml`, `k8s-sandbox/apps/minio.yaml`).
Developer workflows (explicit)
- To change an application manifest: edit the app folder under `k8s-sandbox/<app>/` (each has a `kustomization.yaml`) and open a PR. ArgoCD will sync changes when merged. Examples: `k8s-sandbox/ingress/kustomization.yaml`, `k8s-sandbox/minio/custom-values.yaml`.
- To re-run node-level setup or debug containerd/kubelet issues, follow `k8s-sandbox/README.md` steps (configure `/etc/containerd/config.toml`, enable `containerd` via systemd, then `sudo kubeadm init` / `kubeadm join`). The README contains exact commands and troubleshooting tips (pause image, cgroups).
- Useful commands seen in repo docs:
  - kubectl get nodes
  - sudo kubeadm init --apiserver-advertise-address=<IP> --control-plane-endpoint=<IP> --node-name=<name> --upload-certs
  - kubeadm token create --print-join-command
Conventions and patterns (repo-specific)
- GitOps-first: the source-of-truth for running apps is `k8s-sandbox/apps/*.yaml` which defines ArgoCD Applications pointing to `k8s-sandbox/<component>`.
- Each app uses Kustomize overlays. Edit the overlay under the component folder and optionally update values files stored alongside (example: `k8s-sandbox/minio/custom-values.yaml`, `k8s-sandbox/external-dns/values.yaml`).
- ArgoCD metadata: many manifests include `httproute-grant.yaml` or `link.argocd.argoproj.io/external-link` entries to connect Argo UI links — keep these when moving or splitting apps.
Integration points & external dependencies
- ArgoCD (v2.x) — configured in `k8s-sandbox/argocd/` and wired to manage `k8s-sandbox/apps`.
- CNI: Weave-Net is used in the tutorial, but the repo also contains `cilium/` manifests and docs; follow the `k8s-sandbox/cilium/README.md` guidance if switching to Cilium.
- Secrets: External Secrets and 1Password examples live under `k8s-sandbox/external-secrets/` (see `1password-store.yaml`).
How Copilot should help (practical rules)
- Prefer edits to the YAML under `k8s-sandbox/<component>/` and `k8s-sandbox/apps/*.yaml` rather than ad-hoc kubectl commands. The intended rollout path is: change -> PR -> merge -> ArgoCD sync.
- When modifying cluster bootstrapping content, reference exact commands from `k8s-sandbox/README.md` (containerd config, kubeadm flags). Include the affected file path in the PR description.
- Preserve ArgoCD application fields and kustomize overlays. If you propose splitting an app, update `k8s-sandbox/apps/kustomization.yaml` and corresponding `apps/*.yaml` entries.
- Use examples from the repo when generating snippets (e.g., show `kubeadm` flags or `/etc/containerd/config.toml` pause replacement) rather than generic snippets.
Reference files to inspect
- `k8s-sandbox/README.md` — node bootstrap, containerd, kubeadm, weave-net examples
- `k8s-sandbox/argocd/` — ArgoCD config and examples
- `k8s-sandbox/apps/` — ArgoCD Application entries (source-of-truth for running workloads)
- `k8s-sandbox/*/kustomization.yaml` — per-component overlays
- `k8s-sandbox/external-secrets/1password-store.yaml` — secret-store example
If unsure, ask for runtime context
- If a change depends on a running cluster (IP addresses, node names, ArgoCD URL), request the values from the author rather than guessing.
Keep it short and actionable — prefer small, auditable PRs that update kustomize overlays and `apps/*.yaml` entries.
````
# Copilot Instructions for kubernetes-demo

## Project Overview
This repository contains a Kubernetes setup guide and configuration for deploying a Kubernetes cluster on Arch Linux VMs, primarily targeting Unraid environments but adaptable to other virtualization platforms.

## Architecture & Components

### Core Components
- Control Plane Node: Manages the cluster state and control plane components
  - Required Resources: Min 4GB RAM (8GB+ recommended), 2+ CPU cores
  - Core Services: `containerd`, `kubelet`, `kubeadm`
  
- Worker Nodes: Execute workloads and containers
  - Required Resources: Min 2GB RAM, 1+ CPU cores
  - Core Services: Same as control plane

### Network Architecture
- Uses static IP addressing for nodes (e.g. control plane: 192.168.0.40, worker: 192.168.0.42)
- Pod networking implemented via Weave-Net
- DNS configuration using configurable nameservers (default: Google DNS 8.8.8.8, 8.8.4.4)

## Key Patterns & Conventions

### Node Configuration
- Control plane node naming convention: `arch-kubernetes-control-plane`
- Worker node naming convention: `arch-kubernetes-node0`, `arch-kubernetes-node1`, etc.
- Services configured via systemd (networkd, containerd, kubelet)

### Container Runtime
- Uses `containerd` with systemd cgroups
- Required pause image configuration: `registry.k8s.io/pause:3.9`
- Config location: `/etc/containerd/config.toml`

### Kubernetes Setup
- Cluster initialization via `kubeadm`
- Node joining through generated tokens and discovery hashes
- Pod networking configured post-initialization

## Important Files & Directories
- `/etc/containerd/config.toml`: Container runtime configuration
- `/etc/systemd/network/`: Network configuration files
- `/etc/kubernetes/`: Kubernetes configuration directory
- `k8s-sandbox/apps/`: Application deployments and configurations
- `k8s-sandbox/argocd/`: ArgoCD configuration and setup

## Common Operations
```bash
# Get cluster node status
kubectl get nodes

# Generate new join token
kubeadm token create --print-join-command

# Deploy network solution
kubectl apply -f "https://reweave.azurewebsites.net/k8s/$(kubectl version | base64 | tr -d '\n')/net.yaml"
```

## Development Guidelines
1. Always test configuration changes with `--dry-run` first
2. Verify network connectivity before cluster operations
3. Check service status after configuration changes
4. Use static IP addressing for reliable node communication

## Documentation References
- Official Docs: Kubernetes Documentation — https://kubernetes.io/docs/home/
- Deployment Guide: [Kubernetes the Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way)
- System Reference: [Arch Linux Wiki](https://wiki.archlinux.org/)