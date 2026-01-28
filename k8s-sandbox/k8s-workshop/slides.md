# Kubernetes Workshop
## Understanding Containers and Orchestration

Engineering Team Training

---

## What We'll Cover Today

- What is Docker?
- Understanding Containers
- Why Kubernetes?
- Kubernetes Core Concepts
- Hands-on Architecture

---

## Section 1
### What is Docker?

---

## The Problem: "It Works on My Machine"

- Different environments (dev, staging, prod)
- Missing dependencies
- Version conflicts
- Configuration drift
- OS-specific issues

**Result:** Deployment failures, debugging nightmares

---

## Docker: The Solution

**Docker** packages your application with everything it needs:

- Application code
- Runtime (Node.js, Python, Java, etc.)
- System libraries
- Configuration files
- Environment variables

**Benefit:** Guaranteed consistency across all environments

---

## Docker vs Virtual Machines

| Virtual Machines | Docker Containers |
|-----------------|-------------------|
| Full OS per VM | Shared OS kernel |
| Heavy (GBs) | Lightweight (MBs) |
| Minutes to start | Seconds to start |
| Resource intensive | Efficient |
| Strong isolation | Process isolation |

---

## Docker Key Concepts

**Image**
- Read-only template with instructions
- Built from a Dockerfile
- Stored in registries (Docker Hub, Harbor, ECR)

**Container**
- Running instance of an image
- Isolated process with its own filesystem
- Ephemeral by design

---

## Dockerfile Example

```dockerfile
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
```

**This creates a reproducible build every time**

---

## Section 2
### What is a Container?

---

## Container: Isolated Process

A container is **NOT** a lightweight VM!

**What it really is:**
- A process with isolated namespaces
- Own filesystem (layered)
- Own network stack
- Own process tree
- Resource limits (CPU, memory)

**Key:** Uses Linux kernel features (namespaces, cgroups)

---

## Container Anatomy

**Namespaces** (Isolation)
- PID: Process tree
- NET: Network interfaces
- MNT: Filesystem mounts
- UTS: Hostname
- IPC: Inter-process communication
- USER: User IDs

**Cgroups** (Resource Control)
- CPU limits
- Memory limits
- Disk I/O throttling

---

## Container Lifecycle

```bash
# Pull image from registry
docker pull nginx:latest

# Run container
docker run -d -p 80:80 --name web nginx:latest

# View running containers
docker ps

# Stop container
docker stop web

# Remove container
docker rm web
```

**Containers are ephemeral - data is lost unless persisted!**

---

## Container Networking

**Bridge Network** (default)
- Containers on same bridge can communicate
- Access via container names (DNS)

**Host Network**
- Container uses host's network directly
- No isolation, better performance

**Custom Networks**
- User-defined bridges
- Better isolation and DNS

---

## Container Storage

**Volumes** (Preferred)
- Managed by Docker
- Persist beyond container lifecycle
- Shared between containers

**Bind Mounts**
- Map host directory to container
- Useful for development

**tmpfs Mounts**
- In-memory storage
- Fast but volatile

---

## Section 3
### Why Kubernetes?

---

## Docker is Great, But...

**Problems at scale:**
- How do I run 100 containers across 20 servers?
- How do I ensure containers restart if they crash?
- How do I distribute load across replicas?
- How do I deploy without downtime?
- How do I manage configurations and secrets?
- How do I scale automatically based on load?

**Answer: Container Orchestration**

---

## Kubernetes: Container Orchestrator

**What Kubernetes Does:**
- Automated deployment and scaling
- Self-healing (restarts failed containers)
- Load balancing and service discovery
- Rolling updates and rollbacks
- Secret and configuration management
- Storage orchestration
- Resource optimization

**"Autopilot for your containers"**

---

## Kubernetes vs Docker Swarm vs Nomad

**Kubernetes**
- Most popular (industry standard)
- Steep learning curve
- Rich ecosystem (CNCF)
- Best for complex workloads

**Docker Swarm**
- Easier to learn
- Built into Docker
- Less feature-rich
- Good for simpler setups

**Nomad**
- Lightweight alternative
- Multi-workload (containers, VMs, binaries)
- HashiCorp ecosystem

---

## When to Use Kubernetes

**Good Fit:**
- Microservices architectures
- Multiple teams/services
- Need auto-scaling
- High availability requirements
- Multi-cloud or hybrid cloud
- DevOps/GitOps workflows

**Overkill For:**
- Simple monolithic apps
- Small team/single service
- Minimal traffic/scaling needs
- Learning projects (use Docker Compose first)

---

## Section 4
### Kubernetes Core Concepts

---

## Kubernetes Architecture

**Control Plane** (Master)
- API Server (kubectl talks here)
- etcd (distributed database)
- Scheduler (assigns pods to nodes)
- Controller Manager (maintains desired state)

**Worker Nodes**
- kubelet (runs containers)
- kube-proxy (networking)
- Container runtime (containerd, CRI-O)

---

## Pod: Smallest Unit

**Pod** = One or more containers that share:
- Network namespace (same IP)
- Storage volumes
- Lifecycle

**Why not just containers?**
- Pods enable sidecar patterns
- Init containers for setup
- Shared volume access

**Example:** Web app + logging agent in same pod

---

## Pod Example

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: web
spec:
  containers:
  - name: nginx
    image: nginx:1.25
    ports:
    - containerPort: 80
```

**Pods are ephemeral - they come and go**

---

## Deployment: Declarative Apps

**Deployment** manages:
- ReplicaSet (desired number of pods)
- Rolling updates
- Rollbacks
- Self-healing

**You declare "I want 3 replicas", Kubernetes makes it happen**

---

## Deployment Example

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
```

---

## Service: Stable Networking

**Problem:** Pods have dynamic IPs (they restart)

**Solution:** Service provides:
- Stable DNS name
- Load balancing across pods
- Service discovery

**Types:**
- ClusterIP (internal only)
- NodePort (external via node IP)
- LoadBalancer (cloud provider LB)

---

## Service Example

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: LoadBalancer
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

**DNS:** `nginx-service.default.svc.cluster.local`

---

## ConfigMap & Secret

**ConfigMap:** Non-sensitive configuration
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database_url: "postgres://db:5432/myapp"
```

**Secret:** Sensitive data (base64 encoded)
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-password
type: Opaque
data:
  password: cGFzc3dvcmQxMjM=
```

---

## Namespace: Virtual Clusters

**Namespaces** provide:
- Resource isolation
- RBAC boundaries
- Resource quotas
- Logical separation (dev, staging, prod)

**Default namespaces:**
- `default` (your apps)
- `kube-system` (Kubernetes components)
- `kube-public` (publicly accessible)

---

## Persistent Volumes

**Problem:** Containers are stateless

**Solution:**
- **PersistentVolume (PV):** Storage resource
- **PersistentVolumeClaim (PVC):** Storage request
- **StorageClass:** Dynamic provisioning

**Example:** PostgreSQL database needs persistent storage

---

## Section 5
### Hands-on Architecture

---

## Your Home Lab Setup

**Infrastructure:**
- Multiple nodes (VMs, bare metal, hybrid)
- containerd runtime
- Kubernetes v1.34

**GitOps with ArgoCD:**
- All configs in Git
- Declarative deployments
- Automatic sync
- Rollback capabilities

---

## Networking: Cilium CNI

**Cilium** provides:
- Pod networking (eBPF-based)
- Network policies (security)
- Load balancing
- BGP for LoadBalancer IPs
- Service mesh capabilities

**Why Cilium?**
- High performance
- Advanced observability
- Kubernetes-native

---

## Gateway API (Modern Ingress)

**Gateway API** replaces Ingress:

**HTTPRoute:**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: web-route
spec:
  parentRefs:
  - name: ingress-gateway
  hostnames:
  - "app.example.com"
  rules:
  - backendRefs:
    - name: web-service
      port: 80
```

---

## Monitoring Stack

**VictoriaMetrics:**
- Metrics storage (Prometheus-compatible)
- High performance, low resource usage

**Grafana:**
- Dashboards and visualization
- Alerting

**Promtail + Loki:**
- Log aggregation
- Easy querying

---

## Database: CloudNativePG

**High-availability PostgreSQL:**
- Primary + replicas
- Automatic failover
- Connection pooling (PgBouncer)
- Backup management
- WAL archiving

**Operator pattern:** Extends Kubernetes API

---

## Secret Management

**External Secrets Operator:**
- Syncs from 1Password
- Kubernetes Secret created automatically
- Never commit secrets to Git

**Pattern:**
```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: db-credentials
spec:
  secretStoreRef:
    name: onepassword
  target:
    name: db-password
  data:
  - secretKey: password
    remoteRef:
      key: postgres-prod
      property: password
```

---

## TLS with cert-manager

**Automatic certificate management:**
- Let's Encrypt integration
- Auto-renewal
- Certificate CRDs

**Example:**
```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: app-tls
spec:
  secretName: app-tls-secret
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
  - app.example.com
```

---

## Multi-Source ArgoCD Pattern

**Combine upstream Helm + local customizations:**

```yaml
sources:
- repoURL: https://charts.bitnami.com/bitnami
  chart: postgresql
  targetRevision: 12.1.0
- repoURL: https://github.com/org/repo.git
  path: k8s-sandbox/postgres
  targetRevision: HEAD
```

**Benefits:** Upstream updates + local config

---

## Development Workflow

**1. Make changes locally**
```bash
kubectl kustomize k8s-sandbox/my-app/
```

**2. Validate**
```bash
./scripts/check-yaml.sh
```

**3. Commit to Git**
```bash
git commit -m "feat(my-app): add feature"
git push
```

**4. ArgoCD syncs automatically**

---

## Debugging Kubernetes

**View resources:**
```bash
kubectl get pods -n namespace
kubectl get svc,deploy,ing -A
```

**Describe resource:**
```bash
kubectl describe pod pod-name -n namespace
```

**Logs:**
```bash
kubectl logs pod-name -n namespace -f
kubectl logs deploy/app-name --tail=100
```

**Execute in pod:**
```bash
kubectl exec -it pod-name -n namespace -- /bin/bash
```

---

## Common Issues & Solutions

**CrashLoopBackOff**
- Check logs: `kubectl logs pod-name`
- Check events: `kubectl describe pod pod-name`
- Verify image exists and is pullable

**ImagePullBackOff**
- Check image name and tag
- Verify registry credentials
- Check imagePullSecrets

**Pending Pods**
- Insufficient resources (CPU/memory)
- Node selector constraints
- PVC not bound

---

## Best Practices

**Resource Limits**
```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"
    cpu: "200m"
```

**Health Checks**
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
```

---

## Kubernetes Ecosystem (CNCF)

**Popular Tools:**
- **ArgoCD** - GitOps deployments
- **Helm** - Package manager
- **Prometheus** - Monitoring
- **Cert-Manager** - Certificate automation
- **External-DNS** - DNS automation
- **Velero** - Backup/restore
- **Kyverno** - Policy management
- **Crossplane** - Infrastructure as code

---

## Next Steps

**Continue Learning:**
- Deploy a simple app to your cluster
- Explore kubectl commands
- Study the repo's existing apps
- Experiment with scaling and updates
- Learn about StatefulSets for stateful apps
- Dive into Helm charts

**Resources:**
- kubernetes.io/docs
- CNCF Landscape
- This repo's CLAUDE.md

---

## Questions?

**Thank you for attending!**

Repository: github.com/Starslider/kubernetes-demo

Let's discuss your Kubernetes journey
