# Kubernetes Workshop
## Core Architecture and Cloud Native Concepts

KCNA-Aligned Training

---

## What We'll Cover Today

- Container Fundamentals
- Kubernetes Architecture Deep Dive
- Core Kubernetes Concepts
- Cloud Native Patterns
- Observability, Security & Autoscaling

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
### Kubernetes Architecture Deep Dive

---

## Kubernetes: Distributed System

**Kubernetes is a distributed system** running across multiple nodes

**Key Principles:**
- Declarative configuration (desired state)
- Controllers reconcile actual vs desired state
- API-driven architecture
- Eventually consistent
- Highly available and scalable

**You declare what you want, Kubernetes figures out how to achieve it**

---

## Control Plane Components

**API Server** (`kube-apiserver`)
- Central hub for all cluster communication
- RESTful API (kubectl, controllers, operators talk here)
- Authentication and authorization gateway
- Only component that talks to etcd
- Horizontally scalable

**Key Point:** Everything in Kubernetes goes through the API Server

---

## Control Plane: etcd

**etcd** - Distributed Key-Value Store
- Stores entire cluster state
- Single source of truth
- Strongly consistent (Raft consensus)
- Watches for changes (event-driven)

**What's stored:**
- All resource definitions (Pods, Services, etc.)
- Cluster configuration
- Secrets, ConfigMaps
- Current state vs desired state

**Critical:** Without etcd, your cluster has no memory

---

## Control Plane: Scheduler

**Scheduler** (`kube-scheduler`)
- Watches for newly created Pods with no assigned node
- Selects optimal node for each Pod
- Does NOT start the Pod (kubelet does that)

**Scheduling Factors:**
- Resource requests (CPU, memory)
- Node selectors and affinity rules
- Taints and tolerations
- Pod topology spread constraints
- Data locality

---

## Control Plane: Controller Manager

**Controller Manager** (`kube-controller-manager`)
- Runs multiple controllers in one process
- Each controller watches specific resources
- Reconciliation loops (observe → diff → act)

**Built-in Controllers:**
- Deployment Controller (manages ReplicaSets)
- ReplicaSet Controller (maintains pod replicas)
- Node Controller (monitors node health)
- Service Controller (manages cloud load balancers)
- Job Controller (runs pods to completion)

**Pattern:** Watch desired state → ensure actual state matches

---

## Control Plane: Cloud Controller Manager

**Cloud Controller Manager** (optional)
- Interacts with cloud provider APIs
- Manages cloud-specific resources
- Decouples cloud logic from core Kubernetes

**Cloud Controllers:**
- Node Controller (verifies nodes with cloud provider)
- Route Controller (sets up network routes)
- Service Controller (creates cloud load balancers)
- Volume Controller (creates/attaches cloud volumes)

**Example:** Creates AWS ELB when you create Service type LoadBalancer

---

## Worker Node Components

**kubelet** - Node Agent
- Runs on every worker node
- Ensures containers are running in Pods
- Communicates with API Server
- Reports node and pod status
- Executes pod lifecycle hooks
- Mounts volumes

**Key:** kubelet is the "worker" that does the actual container management

---

## Worker Node: Container Runtime

**Container Runtime** - Runs containers
- Kubernetes uses Container Runtime Interface (CRI)
- Popular runtimes: containerd, CRI-O, Docker (deprecated)

**What it does:**
- Pulls container images from registries
- Unpacks images to disk
- Starts/stops containers
- Manages container lifecycle

**containerd is the most common runtime today**

---

## Worker Node: kube-proxy

**kube-proxy** - Network Proxy
- Runs on every node
- Maintains network rules for Services
- Implements Service abstraction (ClusterIP, NodePort)

**Modes:**
- **iptables** (default) - Creates iptables rules
- **ipvs** (better performance) - Uses Linux IPVS
- **userspace** (legacy)

**Key:** Enables pod-to-pod and service-to-pod networking

---

## Kubernetes Networking Model

**Kubernetes Network Requirements:**
1. All pods can communicate without NAT
2. All nodes can communicate with all pods
3. Pod sees its own IP (no NAT from pod perspective)

**Implemented by CNI (Container Network Interface) plugins:**
- Calico, Cilium, Flannel, Weave, etc.
- Each has different features and performance

**Result:** Flat network where every pod has unique IP

---

## Core Concepts: Pods

**Pod** - Smallest deployable unit
- One or more containers sharing:
  - Network namespace (same localhost)
  - IPC namespace
  - Storage volumes
- Atomic scheduling unit

**When to use multiple containers in a pod:**
- Sidecar pattern (logging, proxies)
- Adapter pattern (normalize output)
- Ambassador pattern (proxy to external services)

**Pods are cattle, not pets - they're ephemeral**

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

## Core Concepts: ReplicaSet

**ReplicaSet** - Maintains pod replicas
- Ensures specified number of pod replicas running
- Creates/deletes pods to match desired count
- Identified by selector labels

**Usually NOT created directly:**
- Deployments manage ReplicaSets
- ReplicaSets manage Pods
- You manage Deployments

**Deployment → ReplicaSet → Pods**

---

## Core Concepts: Deployment

**Deployment** - Declarative updates for Pods
- Creates and manages ReplicaSets
- Rolling updates (zero-downtime deployments)
- Rollback to previous versions
- Pause and resume deployments
- Scale up/down

**Update Strategies:**
- **RollingUpdate** (default) - Gradual replacement
- **Recreate** - Delete all pods then create new ones

**Deployment is your main workload controller**

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

## Core Concepts: StatefulSet

**StatefulSet** - For stateful applications
- Stable, unique network identifiers
- Stable, persistent storage
- Ordered, graceful deployment and scaling
- Ordered, automated rolling updates

**Use cases:**
- Databases (PostgreSQL, MySQL, MongoDB)
- Message queues (Kafka, RabbitMQ)
- Distributed systems requiring stable identity

**Pods get predictable names:** `app-0`, `app-1`, `app-2`

---

## Core Concepts: DaemonSet

**DaemonSet** - Runs on all (or some) nodes
- Ensures a copy of a pod runs on every node
- New nodes automatically get the pod
- Useful for node-level operations

**Use cases:**
- Log collection (Fluentd, Promtail)
- Monitoring agents (Node Exporter)
- Network plugins (CNI agents)
- Storage daemons

**Example:** Cilium CNI runs as DaemonSet

---

## Core Concepts: Job & CronJob

**Job** - Runs pods to completion
- Ensures specified number of successful completions
- Retries on failure
- Parallel execution supported

**CronJob** - Runs Jobs on schedule
- Cron syntax for scheduling
- Creates Jobs at specified times

**Use cases:**
- Batch processing
- Database migrations
- Backups
- Periodic cleanup tasks

---

## Core Concepts: Services

**Problem:** Pods have ephemeral IPs

**Solution: Service** - Stable networking abstraction
- Stable ClusterIP (virtual IP)
- DNS name: `<service>.<namespace>.svc.cluster.local`
- Load balances across pod replicas
- Selector-based (targets pods by labels)

**Services provide service discovery and load balancing**

---

## Service Types

**ClusterIP** (default)
- Only reachable within cluster
- Virtual IP in cluster network
- Most common for internal communication

**NodePort**
- Exposes service on each node's IP at static port
- Range: 30000-32767
- Accessible from outside: `<NodeIP>:<NodePort>`

**LoadBalancer**
- Creates external load balancer (cloud provider)
- Automatically gets external IP
- Built on top of NodePort

**ExternalName**
- Maps service to DNS name (CNAME)
- No proxying involved

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
    app: nginx  # Targets pods with this label
  ports:
  - protocol: TCP
    port: 80          # Service port
    targetPort: 8080  # Container port
```

**DNS:** `nginx-service.default.svc.cluster.local`

---

## Ingress and Gateway API

**Ingress** - HTTP/HTTPS routing
- Layer 7 load balancing
- Host and path-based routing
- TLS termination
- Requires Ingress Controller (nginx, Traefik, etc.)

**Gateway API** (newer, better)
- Successor to Ingress
- More expressive and extensible
- Role-oriented design
- Multiple resource types (Gateway, HTTPRoute, etc.)

**Use for exposing multiple HTTP services with routing rules**

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

## Core Concepts: Storage

**Volumes** - Pod-level storage
- Tied to pod lifecycle
- Shared between containers in same pod
- Types: emptyDir, hostPath, configMap, secret

**PersistentVolume (PV)** - Cluster-level storage resource
- Independent of pod lifecycle
- Provisioned by admin or dynamically
- Access modes: ReadWriteOnce, ReadOnlyMany, ReadWriteMany

**PersistentVolumeClaim (PVC)** - Storage request
- User requests storage with specific size and access mode
- Binds to available PV

**StorageClass** - Dynamic provisioning
- Defines "classes" of storage (fast SSD, slow HDD, etc.)
- Automatic PV creation when PVC is created

---

## Storage Example

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: fast-ssd
---
# In Pod spec:
volumes:
- name: postgres-storage
  persistentVolumeClaim:
    claimName: postgres-pvc
```

---

## Labels and Selectors

**Labels** - Key-value pairs attached to objects
- Used for organization and selection
- Multiple labels per object
- Examples: `app=nginx`, `env=prod`, `tier=frontend`

**Selectors** - Query objects by labels
- **Equality-based:** `app=nginx`, `env!=dev`
- **Set-based:** `env in (prod, staging)`, `tier notin (cache)`

**Use cases:**
- Services select pods: `selector: app=nginx`
- Deployments match pods: `matchLabels: app=nginx`
- kubectl: `kubectl get pods -l app=nginx`

**Labels are how Kubernetes connects resources**

---

## Annotations vs Labels

**Labels:**
- Used for selection and grouping
- Max 63 characters
- Must be valid DNS subdomain
- Used by Kubernetes selectors

**Annotations:**
- Store arbitrary metadata
- No size limit (within reason)
- Not used for selection
- Documentation, tool configuration

**Example annotations:**
```yaml
annotations:
  prometheus.io/scrape: "true"
  kubernetes.io/change-cause: "Update to v2.0"
  description: "Production database"
```

---

## Section 5
### Cloud Native Patterns and KCNA Topics

---

## Cloud Native Architecture

**CNCF Definition:**
Cloud native technologies empower organizations to build and run scalable applications in modern, dynamic environments such as public, private, and hybrid clouds.

**Key Characteristics:**
- Containerized workloads
- Dynamically orchestrated
- Microservices-oriented
- Declarative APIs
- Designed for automation

**Cloud native ≠ running in the cloud (it's about the approach)**

---

## Microservices vs Monoliths

**Monolithic Architecture:**
- Single deployable unit
- Shared database
- Tight coupling
- Scale entire application
- Simpler to start, harder to scale

**Microservices Architecture:**
- Independent services
- Separate databases (data isolation)
- Loose coupling via APIs
- Scale services independently
- Complex to start, easier to scale

**Kubernetes excels at managing microservices**

---

## 12-Factor App Principles

**Key principles for cloud native apps:**
1. **Codebase** - One codebase in version control
2. **Dependencies** - Explicitly declare dependencies
3. **Config** - Store config in environment
4. **Backing Services** - Treat as attached resources
5. **Build, Release, Run** - Strictly separate stages
6. **Processes** - Execute as stateless processes
7. **Port Binding** - Export services via port binding
8. **Concurrency** - Scale out via process model
9. **Disposability** - Fast startup and graceful shutdown
10. **Dev/Prod Parity** - Keep environments similar
11. **Logs** - Treat logs as event streams
12. **Admin Processes** - Run as one-off processes

---

## Observability: The Three Pillars

**Metrics** - Numerical data over time
- CPU, memory usage
- Request rates, latencies
- Error rates
- Tools: Prometheus, VictoriaMetrics

**Logs** - Event records
- Application logs
- System logs
- Audit logs
- Tools: Loki, Elasticsearch, Fluentd

**Traces** - Request flows across services
- Distributed tracing
- Performance bottlenecks
- Service dependencies
- Tools: Jaeger, Tempo, Zipkin

---

## Prometheus and Metrics

**Prometheus** - Open-source monitoring system
- Pull-based metrics collection
- Time-series database
- PromQL query language
- Service discovery (Kubernetes integration)
- Alerting with AlertManager

**ServiceMonitor** (Prometheus Operator)
```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: app-metrics
spec:
  selector:
    matchLabels:
      app: myapp
  endpoints:
  - port: metrics
    interval: 30s
```

---

## Health Checks and Probes

**Liveness Probe** - Is the container alive?
- Restarts container if check fails
- Use for detecting deadlocks

**Readiness Probe** - Is the container ready to serve traffic?
- Removes pod from service endpoints if check fails
- Use for startup time, dependencies

**Startup Probe** - Has the container started?
- Disables liveness/readiness until passing
- Use for slow-starting containers

```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 3
  periodSeconds: 10
```

---

## Security: Defense in Depth

**Layers of Security:**
1. **Cluster** - RBAC, network policies, pod security
2. **Container** - Image scanning, minimal images, non-root
3. **Network** - Service mesh, mTLS, egress control
4. **Data** - Encryption at rest/transit, secret management
5. **Code** - Secure coding, dependency scanning

**Security is multi-layered, not a single tool**

---

## RBAC (Role-Based Access Control)

**Core Components:**
- **ServiceAccount** - Identity for pods
- **Role** - Set of permissions (namespace-scoped)
- **ClusterRole** - Set of permissions (cluster-scoped)
- **RoleBinding** - Grants Role to subject
- **ClusterRoleBinding** - Grants ClusterRole to subject

**Example:**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
```

**Principle of least privilege: Grant minimum necessary permissions**

---

## Network Policies

**NetworkPolicy** - Controls pod-to-pod traffic
- Firewall rules for pods
- Label-based selection
- Ingress and egress rules
- Requires CNI plugin support (Calico, Cilium, etc.)

**Example: Deny all, allow specific**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-allow-frontend
spec:
  podSelector:
    matchLabels:
      app: api
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - port: 8080
```

---

## Pod Security Standards

**Three levels (least to most restrictive):**

**Privileged** - Unrestricted (no restrictions)

**Baseline** - Minimally restrictive
- Prevents known privilege escalations
- Allows default capabilities

**Restricted** - Heavily restricted (best practice)
- Non-root containers
- Disallows privilege escalation
- Drops all capabilities
- Read-only root filesystem

**Enforced via Pod Security Admission or external tools (Kyverno, OPA)**

---

## Resource Management: Requests vs Limits

**Requests** - Guaranteed resources
- Used by scheduler for placement
- Container gets at least this much
- QoS class determination

**Limits** - Maximum resources
- Container cannot exceed this
- OOMKilled if memory limit exceeded
- CPU throttled if CPU limit exceeded

**Best Practice:**
```yaml
resources:
  requests:
    cpu: "100m"      # 0.1 CPU core
    memory: "128Mi"
  limits:
    cpu: "500m"      # 0.5 CPU core
    memory: "512Mi"
```

**Always set requests and limits to avoid noisy neighbors**

---

## QoS Classes

**Guaranteed** (highest priority)
- Requests = Limits for all containers
- Least likely to be evicted

**Burstable** (medium priority)
- Requests < Limits
- Can use extra resources when available

**BestEffort** (lowest priority)
- No requests or limits set
- First to be evicted under pressure

**QoS affects scheduling and eviction behavior**

---

## Horizontal Pod Autoscaler (HPA)

**HPA** - Automatically scales replica count
- Monitors metrics (CPU, memory, custom)
- Adjusts Deployment/StatefulSet replicas
- Reconciliation loop (every 15 seconds)

**Example:**
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

---

## Vertical Pod Autoscaler (VPA)

**VPA** - Automatically adjusts resource requests/limits
- Monitors actual resource usage
- Updates requests/limits recommendations
- Can automatically apply changes (requires pod restart)

**Modes:**
- **Off** - Only recommendations
- **Initial** - Set on pod creation only
- **Auto** - Update running pods (requires restart)

**Use VPA when you don't know the right resource values**

---

## Cluster Autoscaler

**Cluster Autoscaler** - Adjusts cluster size
- Adds nodes when pods can't be scheduled
- Removes nodes when underutilized
- Cloud provider integration required

**Works with:**
- AWS Auto Scaling Groups
- GCP Managed Instance Groups
- Azure Virtual Machine Scale Sets

**Complete autoscaling = HPA + VPA + Cluster Autoscaler**

---

## Application Delivery: GitOps

**GitOps** - Git as single source of truth
- Declarative infrastructure and applications
- Git repository contains desired state
- Automated sync to cluster
- Version control for everything
- Easy rollback (git revert)

**Popular Tools:**
- **ArgoCD** - Kubernetes-native GitOps
- **Flux** - GitOps toolkit
- **Jenkins X** - CI/CD for Kubernetes

**GitOps = Infrastructure as Code + Pull Requests + CI/CD**

---

## Helm: Package Manager

**Helm** - Package manager for Kubernetes
- Packages called "Charts"
- Templating for Kubernetes manifests
- Version management
- Dependency management

**Chart Structure:**
```
mychart/
  Chart.yaml       # Chart metadata
  values.yaml      # Default values
  templates/       # Kubernetes manifests
    deployment.yaml
    service.yaml
```

**Helm simplifies deploying complex applications**

---

## Application Delivery Strategies

**Rolling Update** (default)
- Gradual replacement of old pods
- Zero downtime
- Configurable max surge and max unavailable

**Blue/Green Deployment**
- Two identical environments (blue and green)
- Switch traffic instantly
- Easy rollback
- Requires 2x resources

**Canary Deployment**
- Gradual traffic shift to new version
- Monitor metrics before full rollout
- Progressive delivery
- Tools: Flagger, Argo Rollouts

---

## ConfigMaps and Secrets

**ConfigMap** - Non-sensitive configuration
- Environment variables
- Command-line arguments
- Configuration files

**Secret** - Sensitive data
- Base64 encoded (not encrypted!)
- Passwords, tokens, keys
- Should be encrypted at rest (etcd encryption)

**Best Practice:**
- External secret management (Vault, AWS Secrets Manager)
- Tools: External Secrets Operator, Sealed Secrets

```yaml
envFrom:
- configMapRef:
    name: app-config
- secretRef:
    name: app-secrets
```

---

## Debugging Kubernetes

**Essential kubectl commands:**
```bash
# View resources
kubectl get pods -n namespace -o wide
kubectl get events --sort-by=.metadata.creationTimestamp

# Detailed information
kubectl describe pod pod-name -n namespace

# Logs
kubectl logs pod-name -n namespace -f --tail=100
kubectl logs -l app=myapp --all-containers=true

# Execute commands
kubectl exec -it pod-name -n namespace -- /bin/sh

# Port forwarding
kubectl port-forward svc/myapp 8080:80

# Debug with ephemeral container (K8s 1.23+)
kubectl debug pod-name -it --image=busybox
```

---

## Common Issues & Solutions

**CrashLoopBackOff**
- Application exiting immediately
- Check logs and container CMD/ENTRYPOINT
- Verify dependencies are ready

**ImagePullBackOff**
- Image doesn't exist or wrong tag
- Registry authentication issues
- Check imagePullSecrets

**Pending Pods**
- Insufficient cluster resources
- Node selector/affinity constraints not met
- PVC not bound or storage unavailable

**OOMKilled (Out of Memory)**
- Container exceeded memory limit
- Increase memory limit or optimize app
- Check for memory leaks

---

## CNCF Landscape

**CNCF** (Cloud Native Computing Foundation)
- Home of Kubernetes and 100+ projects
- Three maturity levels: Sandbox, Incubating, Graduated

**Key CNCF Projects:**
- **Runtime:** Kubernetes, containerd, CRI-O
- **Orchestration:** Helm, Argo, Flux
- **Observability:** Prometheus, Grafana, Jaeger, Fluentd
- **Service Mesh:** Istio, Linkerd, Envoy
- **Security:** Falco, cert-manager, SPIFFE/SPIRE
- **Storage:** Rook, Longhorn, Velero

**landscape.cncf.io - Explore 1000+ tools**

---

## Best Practices Summary

**Workloads:**
- Always set resource requests and limits
- Use health probes (liveness, readiness, startup)
- Don't run as root
- Use specific image tags (not `latest`)

**Security:**
- Enable RBAC and follow least privilege
- Use Network Policies
- Scan container images
- Encrypt secrets at rest

**Operations:**
- Use GitOps for deployments
- Implement observability (metrics, logs, traces)
- Plan for scaling (HPA, VPA, Cluster Autoscaler)
- Regular backups with Velero or similar

---

## Next Steps: KCNA Certification

**KCNA** (Kubernetes and Cloud Native Associate)
- Entry-level certification from CNCF
- Covers fundamentals we discussed today
- 90-minute exam, 60 questions
- Online proctored exam

**Exam Domains:**
- Kubernetes Fundamentals (46%)
- Container Orchestration (22%)
- Cloud Native Architecture (16%)
- Cloud Native Observability (8%)
- Cloud Native Application Delivery (8%)

**This workshop covered most KCNA topics!**

---

## Hands-on Practice

**Essential Practice:**
1. Set up local Kubernetes (minikube, kind, k3s)
2. Deploy sample applications
3. Experiment with kubectl commands
4. Break things and fix them
5. Implement health probes and resource limits
6. Practice troubleshooting

**Learning Platforms:**
- killercoda.com (interactive K8s scenarios)
- kubernetes.io/docs/tutorials
- play-with-k8s.com (temporary clusters)

**Hands-on experience is crucial**

---

## Additional Resources

**Official Documentation:**
- kubernetes.io/docs
- cncf.io (CNCF projects)
- landscape.cncf.io (ecosystem overview)

**Books:**
- "Kubernetes Up & Running" (O'Reilly)
- "Cloud Native DevOps with Kubernetes" (O'Reilly)

**Practice:**
- GitHub repos with sample apps
- Helm charts for real applications
- KCNA exam prep resources

**Community:**
- Kubernetes Slack
- CNCF Community groups

---

## Questions?

**Thank you for attending!**

Repository: github.com/Starslider/kubernetes-demo

Let's discuss your Kubernetes journey
