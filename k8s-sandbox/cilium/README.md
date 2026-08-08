# Cilium Configuration

Local Cilium CRs (BGP, LB pools, Gateway grants, optional WSL NodeConfig).  
Agent/operator come from multi-source ArgoCD app `k8s-sandbox/apps/cilium.yaml` (Helm **1.19.4** + this path).

## Decision: WSL GPU stays Cilium-free

**`gpu-worker-3090` (Ubuntu on WSL2) permanently does not run the Cilium agent** for now.

| Why | Detail |
|-----|--------|
| Host RAM | Physical box ~**8 Gi**; WSL sees ~5–7 Gi allocatable. Agent + maps fight Ollama. |
| Mirrored `eth0` | Cilium host datapath on that NIC killed kubelet TCP → NotReady / “logs gone”. |
| Soft profile | `wsl-gpu-nodeconfig.yaml` was **not** proven safe; kept optional only. |

**In scope for GitOps:** label kill switch, optional NodeConfig CR, docs, GPU workload patterns.  
**Out of scope:** `.wslconfig`, Windows firewall, WSL keepalive, host `/etc/cni/net.d` files.

## Cluster-wide posture (real Linux nodes)

Do **not** change cluster-wide KPR / tcx / tunnel / L2 for one WSL box. Arch + Flatcar keep:

- `kubeProxyReplacement=true`, VXLAN tunnel, Hubble, Gateway API, L2, BGP  
- Pod CIDR `10.244.0.0/16`  
- `k8sServiceHost=192.168.1.30` / `k8sServicePort=6443`

## Kill switch (label affinity)

Helm sets **nodeAffinity** so agent **and** envoy never land on:

```text
networking.home/cilium=skip
```

Prefer **label** over `kubernetes.io/hostname NotIn` (survives renames; multi-node).  
Any live hostname `NotIn` patches are obsolete once Argo has synced this affinity.

| Action | Command |
|--------|---------|
| Ensure quarantine | `kubectl label node gpu-worker-3090 networking.home/cilium=skip --overwrite` |
| (Lab only) allow schedule | `kubectl label node gpu-worker-3090 networking.home/cilium-` |

**kube-proxy** has **no** skip affinity — it must keep running on WSL nodes for Services while KPR is off *for that node only* (no agent = no KPR on that host). Do not add exclusion to the kube-proxy DaemonSet.

## Bootstrap labels + taint (required when joining the GPU node)

Set these on **first join** (or immediately after):

```bash
kubectl label node gpu-worker-3090 \
  networking.home/cilium=skip \
  networking.home/cni-profile=wsl \
  accelerator=nvidia-rtx-3090 \
  node.kubernetes.io/gpu=true \
  nvidia.com/gpu.present=true \
  --overwrite

# Only Ollama (and GPU system DaemonSets) may schedule here
kubectl taint node gpu-worker-3090 nvidia.com/gpu=true:NoSchedule --overwrite
```

| Label | Purpose |
|-------|---------|
| `networking.home/cilium=skip` | **Required** — Cilium agent + envoy never schedule |
| `networking.home/cni-profile=wsl` | Marks host-managed bridge CNI; optional NodeConfig selector |
| `accelerator=nvidia-rtx-3090` | GPU scheduling |
| `node.kubernetes.io/gpu=true` | Convenience selector |
| `nvidia.com/gpu.present=true` | Device-plugin / inventory |

| Taint | Purpose |
|-------|---------|
| `nvidia.com/gpu=true:NoSchedule` | **Required** — blocks all non-GPU workloads (Postgres, Argo, apps, …). Only pods that tolerate `nvidia.com/gpu` may schedule (Ollama + nvidia-device-plugin). |

**Allowed on this node:** `ollama-gpu`, `nvidia-device-plugin`, `kube-proxy` (bridge CNI needs kube-proxy).  
**Not allowed:** any other application pods, node-exporter, promtail, CNPG instances, etc.
## Host CNI runbook (WSL bridge — host-managed)

CNI on this node is **not** Cilium. Bridge is installed/maintained on the host (out of GitOps).

If node is **NotReady** or pods hang:

1. Confirm WSL is running (Windows keepalive / log in if needed).  
2. On the node: kubelet + containerd active; `kubectl get node gpu-worker-3090`.  
3. Check `/etc/cni/net.d`: **bridge-only**.  
   - **Bad:** orphan `05-cilium.conflist` / `05-cilium.conf` **without** a healthy agent → delete Cilium CNI files, leave bridge.  
   - **Good:** local bridge (e.g. `10.244.99.0/24`) only.  
4. Confirm labels still include `networking.home/cilium=skip`.  
5. kube-proxy pod Running on the node.

Cross-node pod networking from WSL is **limited** (no full Cilium mesh). GPU apps often use `hostNetwork: true` for egress/DNS (see Ollama).

## Observability DaemonSets on WSL

Same kill switch: **do not** schedule these on `networking.home/cilium=skip` nodes
(they need cluster DNS / Loki / scrape paths the bridge CNI cannot provide):

| Component | Why skip on WSL |
|-----------|-----------------|
| **Promtail** | Cannot push to `loki:3100` (DNS/ClusterIP timeout) |
| **Loki canary** | Cannot reach Loki service |
| **prometheus-node-exporter** | Noisy WSL filesystem metrics; restarts under NotReady; RAM better left for GPU |

Loki **server**, Grafana, VictoriaMetrics stay on real Linux nodes only.

## GPU workloads (Ollama only)

The node is tainted `nvidia.com/gpu=true:NoSchedule`. **Only Ollama** should run
application pods here — every GPU workload **must** tolerate that taint.

Pattern used by `k8s-sandbox/ollama/ollama-gpu.yaml`:

```yaml
spec:
  runtimeClassName: nvidia
  # Often required on WSL bridge CNI for public DNS / registry pull:
  # hostNetwork: true
  # dnsPolicy: Default
  nodeSelector:
    kubernetes.io/hostname: gpu-worker-3090
    # or: accelerator: nvidia-rtx-3090
  tolerations:
    - key: nvidia.com/gpu
      operator: Exists
      effect: NoSchedule
  containers:
    - name: app
      resources:
        requests:
          nvidia.com/gpu: "1"
        limits:
          nvidia.com/gpu: "1"
```

Do **not** add this toleration to non-GPU apps (Postgres, monitoring sidecars, etc.).
Keep system memory requests modest (~2 Gi); weights live in 24 Gi VRAM.
## Optional lab NodeConfig

`wsl-gpu-nodeconfig.yaml` applies **only if** an agent runs on a node with `cni-profile=wsl`.  
Default posture: **agent never runs** (`cilium=skip`). Do not remove the skip label without an explicit lab procedure and a console independent of kubectl.

## Components

| File | Purpose |
|------|---------|
| `bgpconf.yaml` | BGP CRs (control-plane) |
| `IPAddressPool.yaml` | LB pool + L2 policy |
| `httproute-grant.yaml` | Gateway grants |
| `wsl-gpu-nodeconfig.yaml` | Optional soft profile (lab only) |
| `kustomization.yaml` | Bundles CRs for Argo |

## Usage

```bash
kubectl kustomize k8s-sandbox/cilium
kubectl apply -k k8s-sandbox/cilium
# Helm agent: Argo app "cilium" (apps/cilium.yaml)
```
