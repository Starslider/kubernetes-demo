# Kubernetes Workshop
## From Containers to Cloud Native

A Beginner's Introduction

---

## Today's Journey

**Part 1:** The Container Revolution (15 min)
- Why containers matter
- What problem they solve

**Part 2:** Enter Kubernetes (20 min)
- What is Kubernetes?
- Core concepts explained simply

**Part 3:** Cloud Native Thinking (20 min)
- Modern application patterns
- Getting started with Kubernetes

---

## Part 1
### The Container Revolution

---

## The Classic Problem

**Imagine this scenario:**

Your developer says: **"It works on my laptop!"**

But in production...
- ❌ Different operating system
- ❌ Missing dependencies
- ❌ Wrong versions installed
- ❌ Different configuration

**Sound familiar?**

---

## Enter: Containers

Think of a container like a **frozen pizza** 🍕

- **Standardized** - Every pizza has the same packaging
- **Self-contained** - All ingredients included
- **Portable** - Works in any oven
- **Isolated** - Keeps separate from other food

**A container packages your app + everything it needs to run**

---

## What's Inside a Container?

```
📦 Your Application Container
   ├── Your application code
   ├── Runtime (Node.js, Python, Java)
   ├── Libraries and dependencies
   ├── Configuration files
   └── Environment settings
```

**Ship this once, run it anywhere!**

---

## Container vs Traditional

**Traditional Deployment:**
```
Server 1: OS → Many apps fighting for resources
Server 2: OS → Different versions, conflicts
Server 3: OS → "Why isn't this working?!"
```

**With Containers:**
```
Server 1: OS → 📦📦📦 (isolated apps)
Server 2: OS → 📦📦📦 (same containers)
Server 3: OS → 📦📦📦 (predictable!)
```

**Each container is isolated and predictable**

---

## Why Developers Love Containers

✅ **Consistency** - Same everywhere
✅ **Fast** - Start in seconds
✅ **Lightweight** - Not full VMs
✅ **Isolated** - No conflicts
✅ **Portable** - Run anywhere

**"Build once, run anywhere"**

---

## The Next Challenge

**Containers solved one problem...**
- ✅ Packaging applications

**But created new questions:**
- ❓ What if I have 100 containers?
- ❓ What if a container crashes?
- ❓ How do I update containers?
- ❓ How do containers find each other?
- ❓ How do I scale when busy?

**We need an orchestrator!**

---

## Part 2
### Enter Kubernetes

---

## What is Kubernetes?

**Think of Kubernetes as an operating system for your containers**

Just like your laptop's OS:
- Schedules programs
- Monitors health
- Manages resources
- Handles networking
- Restarts crashes

**Kubernetes does this for containers, at scale**

---

## The Kubernetes Promise

**You tell Kubernetes:**
> "I want 5 copies of my web app running"

**Kubernetes ensures:**
- ✅ Creates 5 containers
- ✅ Distributes across servers
- ✅ Restarts if any crash
- ✅ Balances traffic between them
- ✅ Updates them safely
- ✅ Scales them automatically

**You describe what you want. Kubernetes makes it happen.**

---

## Real-World Analogy

**Kubernetes is like a restaurant manager:**

You (chef) → "I need these dishes made"

Manager (Kubernetes):
- Assigns tasks to kitchen staff (servers)
- Monitors if staff are working (health checks)
- Replaces sick staff (restarts crashed containers)
- Handles more customers (scales up)
- Coordinates everything smoothly

---

## Kubernetes Architecture (Simple View)

```
┌─────────────────────────────────────┐
│         Control Plane               │
│    (The Brain - Makes decisions)    │
│                                     │
│  • Receives your requests           │
│  • Schedules containers             │
│  • Monitors everything              │
└─────────────────────────────────────┘
           ↓ ↓ ↓
┌────────────┐ ┌────────────┐ ┌────────────┐
│  Worker 1  │ │  Worker 2  │ │  Worker 3  │
│            │ │            │ │            │
│   [Pods]   │ │   [Pods]   │ │   [Pods]   │
│            │ │            │ │            │
│(Runs your  │ │(Runs your  │ │(Runs your  │
│containers) │ │containers) │ │containers) │
└────────────┘ └────────────┘ └────────────┘
```

---

## Core Concept #1: Pods

**Pod** = The smallest unit in Kubernetes

Think of it as a **wrapper around your container(s)**

```
┌─────────────────┐
│      Pod        │
│  ┌───────────┐  │
│  │ Container │  │
│  │  (Your    │  │
│  │   App)    │  │
│  └───────────┘  │
└─────────────────┘
```

**One pod usually = one container**

Pods are temporary - they can be replaced anytime

---

## Core Concept #2: Deployments

**Deployment** = Blueprint for running your app

You say:
```yaml
I want:
  - 3 copies of my web app
  - Using image: my-app:v1.0
  - Give each 512MB RAM
```

Kubernetes creates and manages them automatically

**Deployments ensure your desired state is maintained**

---

## Core Concept #3: Services

**Problem:** Pods come and go, IPs change

**Solution: Service** = Stable address for your app

```
Internet Request
      ↓
   Service (stable address)
      ↓
Distributes to → 📦 Pod 1
                📦 Pod 2
                📦 Pod 3
```

**Service = Load balancer + DNS name + stable endpoint**

---

## Putting It Together

**Example: Running a Web App**

1. **You create:** Deployment (describes your app)
2. **Kubernetes creates:** 3 Pods (your app running)
3. **You create:** Service (stable access point)
4. **Kubernetes handles:**
   - Restarting crashed pods
   - Balancing traffic
   - Rolling updates
   - Scaling

**You manage the "what", Kubernetes handles the "how"**

---

## How You Talk to Kubernetes

**kubectl** = Command-line tool

```bash
# Deploy your app
kubectl apply -f my-app.yaml

# Check if it's running
kubectl get pods

# See your services
kubectl get services

# Scale to 5 copies
kubectl scale deployment my-app --replicas=5
```

**Simple commands to control everything**

---

## Real Example: Deploy a Web App

```yaml
# Tell Kubernetes what you want
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-website
spec:
  replicas: 3                # 3 copies please
  template:
    spec:
      containers:
      - name: website
        image: nginx:latest   # Which container image
```

**That's it! Kubernetes does the rest.**

---

## Configuration: The Kubernetes Way

**Don't store passwords in containers!**

**ConfigMap** - Regular settings
```yaml
database_host: "db.example.com"
cache_size: "1000"
```

**Secret** - Sensitive data
```yaml
database_password: "secretpw123"
api_key: "key-abc-xyz"
```

**Kubernetes injects these into your containers**

---

## Storage: Making Data Persist

**Remember:** Containers are temporary

**For data that needs to survive:**

```
┌──────────┐    ┌──────────────┐    ┌──────────────┐
│Your Pod  │───→│ PersistentVC │───→│ Persistent   │
│          │    │   (Claim)    │    │   Volume     │
│ [App]    │    │              │    │   (Storage)  │
└──────────┘    └──────────────┘    └──────────────┘
 (temporary)      (request)           (actual disk)
```

**How it works:**
1. **Persistent Volume (PV)** - Actual storage resource
2. **PersistentVolumeClaim (PVC)** - Request for storage
3. **Pod** - Uses the PVC to access storage

**Use for databases, uploaded files, etc.**

---

## Part 3
### Cloud Native Thinking

---

## What is "Cloud Native"?

**Cloud Native = Building apps designed for modern infrastructure**

**Traditional App:**
- Big monolith
- Runs on one server
- Hard to update
- Scales by adding bigger servers

**Cloud Native App:**
- Broken into small services
- Runs on many containers
- Easy to update
- Scales by adding more containers

---

## Microservices Explained

**Monolith:**
```
┌───────────────────────┐
│   One Big App         │
│  ┌─────────────────┐  │
│  │ User Login      │  │
│  │ Product Catalog │  │
│  │ Shopping Cart   │  │
│  │ Payment         │  │
│  └─────────────────┘  │
└───────────────────────┘
```

**Microservices:**
```
📦 Login Service  →  📦 Catalog Service
                 ↘              ↓
                   📦 Cart Service
                              ↓
                    📦 Payment Service
```

**Each service = independent, scalable, updateable**

---

## Why Microservices + Kubernetes?

**Benefits:**

1. **Scale what you need**
   - Black Friday? Scale payment service
   - Normal day? Scale down

2. **Update safely**
   - Update cart service without touching payment
   - Roll back if issues

3. **Team autonomy**
   - Different teams own different services
   - Deploy independently

4. **Reliability**
   - One service fails? Others keep running

---

## Observability: Watching Your Apps

**Three pillars of observability:**

**1. Metrics** 📊
- "CPU is at 80%"
- "Response time: 200ms"
- Tools: Prometheus, Grafana

**2. Logs** 📝
- "User john logged in"
- "Error: database timeout"
- Tools: Loki, Elasticsearch

**3. Traces** 🔍
- "Request went: API → Database → Cache"
- Find slow operations
- Tools: Jaeger, Tempo

---

## Health Checks: Staying Alive

**Kubernetes constantly checks your containers:**

**Liveness:** "Are you alive?"
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
```
→ If fails: Restart container

**Readiness:** "Ready for traffic?"
```yaml
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
```
→ If fails: Stop sending traffic

---

## Auto-Scaling: Growing and Shrinking

**Horizontal Pod Autoscaler (HPA)**

```
Normal traffic:  📦📦     (2 pods)

Traffic spike:   📦📦📦📦📦 (5 pods)

Back to normal:  📦📦     (2 pods)
```

**Kubernetes watches CPU/memory and scales automatically**

**You set min/max, Kubernetes adjusts based on load**

---

## Security Basics

**Best Practices:**

1. **Don't run as root**
   ```yaml
   securityContext:
     runAsNonRoot: true
   ```

2. **Limit what containers can do**
   ```yaml
   securityContext:
     allowPrivilegeEscalation: false
   ```

3. **Use secrets properly**
   - Never in code
   - Never in images
   - Use Kubernetes Secrets

4. **Network policies**
   - Control who can talk to whom

---

## Deployment Strategies

**Rolling Update** (default)
```
v1: 📦📦📦  →  v1: 📦📦⚪  →  v1: 📦⚪⚪  →  v2: ⚪⚪⚪
v2:         →  v2: ⚪📦   →  v2: ⚪📦📦  →  (done)
```
Gradual replacement, zero downtime

**Blue/Green**
```
Blue (v1):  📦📦📦  ←  All traffic
Green (v2): 📦📦📦  (ready)

Switch! →

Blue (v1):  📦📦📦  (can rollback)
Green (v2): 📦📦📦  ←  All traffic
```

---

## GitOps: Infrastructure as Code

**Traditional:**
```
Developer → Manual commands → Production
            kubectl apply...
```

**GitOps:**
```
Developer → Git commit → Automatic deployment
            (everything versioned)
```

**Benefits:**
- Version control for infrastructure
- Easy rollbacks (git revert)
- Audit trail (who changed what)
- Automated and consistent

**Tool: ArgoCD, Flux**

---

## Common kubectl Commands

```bash
# See what's running
kubectl get pods
kubectl get services
kubectl get deployments

# Get details
kubectl describe pod my-pod

# View logs
kubectl logs my-pod

# Access container
kubectl exec -it my-pod -- sh

# Delete resources
kubectl delete pod my-pod
```

**These 90% of what you'll use daily**

---

## Troubleshooting 101

**Pod not starting?**
```bash
kubectl describe pod my-pod
# Look at Events section
```

**App crashed?**
```bash
kubectl logs my-pod
# Check error messages
```

**Can't access app?**
```bash
kubectl get services
# Verify service configuration
```

**Most issues are in: image name, config, or resources**

---

## Package Management: Helm

**Helm** = Package manager for Kubernetes

Think of it like **apt, yum, or npm** for Kubernetes

```yaml
# Instead of managing 20+ YAML files
helm install my-app stable/wordpress

# Upgrades made easy
helm upgrade my-app stable/wordpress --version 2.0

# Easy rollback
helm rollback my-app
```

**Benefits:**
- Reusable application templates
- Version management
- Easy updates and rollbacks
- Share packages via Helm charts

---

## Configuration Management: Kustomize

**Kustomize** = Template-free customization

**The problem:** Same app, different environments

```
Base Configuration (common)
    ↓
├─> Dev (small resources, debug enabled)
├─> Staging (medium resources)
└─> Production (large resources, monitoring)
```

**How it works:**
```yaml
# Base deployment
resources:
  - deployment.yaml

# Production overlay
resources:
  - ../../base
patches:
  - replica-count.yaml
  - resource-limits.yaml
```

**Built into kubectl!**

---

## GitOps with ArgoCD

**ArgoCD** = Continuous delivery for Kubernetes

**Traditional CI/CD:**
```
Git → CI Pipeline → kubectl apply → Cluster
      (push model - pipeline has cluster access)
```

**ArgoCD (GitOps):**
```
Git → ArgoCD watches → Syncs automatically
      (pull model - cluster pulls changes)
```

**Key Features:**
- 🔄 Automatic sync from Git
- 👁️ Visual dashboard of deployments
- 🔙 Easy rollback to any Git commit
- 🎯 Multi-cluster management
- 📊 Health monitoring

**Your Git repo becomes the single source of truth**

---

## Learning Resources

**Free Resources:**
- **kubernetes.io/docs** - Official docs
- **killercoda.com** - Interactive labs
- **play-with-k8s.com** - Free sandbox

**Books:**
- "Kubernetes Up & Running"
- "The Kubernetes Book"

**Practice:**
1. Deploy simple apps locally
2. Break things intentionally
3. Fix them
4. Repeat!

**Hands-on is the best way to learn**

---

## The Kubernetes Ecosystem (CNCF)

**Cloud Native Computing Foundation (CNCF)**

Over 1000+ tools in the ecosystem:

**Key Categories:**
- **Container Runtime:** containerd, CRI-O
- **Orchestration:** Kubernetes, Helm
- **Observability:** Prometheus, Grafana
- **Service Mesh:** Istio, Linkerd
- **Security:** Falco, cert-manager
- **Storage:** Rook, Longhorn

**Kubernetes is just the foundation!**

---

## Key Takeaways

1. **Containers** = Portable, isolated application packages
2. **Kubernetes** = Automates container management at scale
3. **Declarative** = You say what, K8s figures out how
4. **Cloud Native** = Modern way to build scalable apps
5. **Start Simple** = Learn basics, then expand

**Don't try to learn everything at once!**

**Master the fundamentals first.**

---

## Your Next Steps

**Week 1-2:** Basics
- Set up local cluster
- Practice with kubectl
- Understand core resources

**Week 3-4:** Core Concepts
- Master Deployments, Services, ConfigMaps
- Work with Pods and ReplicaSets
- Practice scaling and updates

**Month 2:** Advanced Topics
- Storage and networking
- Security best practices
- Monitoring and observability

**Month 3:** Real Projects
- Build multi-service applications
- Implement GitOps with ArgoCD
- Use Helm and Kustomize

---

## Questions?

**Thank you for your time!**

**Remember:**
- Start small
- Practice hands-on
- Community is helpful
- It's okay to not know everything

**Resources:**
- kubernetes.io/docs
- CNCF Slack
- GitHub: github.com/Starslider/kubernetes-demo

**Let's discuss your questions!**
