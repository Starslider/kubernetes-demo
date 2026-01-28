# Kubernetes Workshop
## Container und Orchestrierung verstehen

Technische Schulung für Engineers

---

## Was wir heute behandeln

- Was ist Docker?
- Container verstehen
- Warum Kubernetes?
- Kubernetes Kernkonzepte
- Hands-on Architektur

---

## Sektion 1
### Was ist Docker?

---

## Das Problem: "Bei mir funktioniert es"

- Unterschiedliche Umgebungen (dev, staging, prod)
- Fehlende Abhängigkeiten
- Versionskonflikte
- Konfigurationsdrift
- OS-spezifische Probleme

**Ergebnis:** Deployment-Fehler, Debugging-Albträume

---

## Docker: Die Lösung

**Docker** verpackt deine Anwendung mit allem was sie braucht:

- Anwendungscode
- Runtime (Node.js, Python, Java, etc.)
- System-Bibliotheken
- Konfigurationsdateien
- Umgebungsvariablen

**Vorteil:** Garantierte Konsistenz über alle Umgebungen

---

## Docker vs Virtuelle Maschinen

| Virtuelle Maschinen | Docker Container |
|---------------------|------------------|
| Volles OS pro VM | Geteilter OS Kernel |
| Schwer (GBs) | Leichtgewicht (MBs) |
| Minuten zum Starten | Sekunden zum Starten |
| Ressourcen-intensiv | Effizient |
| Starke Isolation | Prozess-Isolation |

---

## Docker Schlüsselkonzepte

**Image**
- Read-only Template mit Anweisungen
- Gebaut aus einem Dockerfile
- Gespeichert in Registries (Docker Hub, Harbor, ECR)

**Container**
- Laufende Instanz eines Images
- Isolierter Prozess mit eigenem Dateisystem
- Ephemer by Design

---

## Dockerfile Beispiel

```dockerfile
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
```

**Das erstellt jedes Mal einen reproduzierbaren Build**

---

## Sektion 2
### Was ist ein Container?

---

## Container: Isolierter Prozess

Ein Container ist **KEINE** leichtgewichtige VM!

**Was es wirklich ist:**
- Ein Prozess mit isolierten Namespaces
- Eigenes Dateisystem (layered)
- Eigener Netzwerk-Stack
- Eigener Prozessbaum
- Ressourcen-Limits (CPU, Memory)

**Wichtig:** Nutzt Linux Kernel Features (Namespaces, Cgroups)

---

## Container Anatomie

**Namespaces** (Isolation)
- PID: Prozessbaum
- NET: Netzwerk-Interfaces
- MNT: Dateisystem-Mounts
- UTS: Hostname
- IPC: Inter-Prozess-Kommunikation
- USER: User IDs

**Cgroups** (Ressourcen-Kontrolle)
- CPU Limits
- Memory Limits
- Disk I/O Drosselung

---

## Container Lifecycle

```bash
# Image aus Registry ziehen
docker pull nginx:latest

# Container starten
docker run -d -p 80:80 --name web nginx:latest

# Laufende Container anzeigen
docker ps

# Container stoppen
docker stop web

# Container entfernen
docker rm web
```

**Container sind ephemer - Daten gehen verloren wenn nicht persistiert!**

---

## Container Netzwerk

**Bridge Network** (Standard)
- Container im selben Bridge können kommunizieren
- Zugriff via Container-Namen (DNS)

**Host Network**
- Container nutzt Host-Netzwerk direkt
- Keine Isolation, bessere Performance

**Custom Networks**
- Benutzerdefinierte Bridges
- Bessere Isolation und DNS

---

## Container Storage

**Volumes** (Bevorzugt)
- Von Docker verwaltet
- Persistieren über Container-Lifecycle hinaus
- Zwischen Containern geteilt

**Bind Mounts**
- Host-Verzeichnis zu Container gemappt
- Nützlich für Entwicklung

**tmpfs Mounts**
- Im-Memory Storage
- Schnell aber flüchtig

---

## Sektion 3
### Warum Kubernetes?

---

## Docker ist großartig, aber...

**Probleme bei Skalierung:**
- Wie starte ich 100 Container auf 20 Servern?
- Wie stelle ich sicher dass Container neu starten wenn sie crashen?
- Wie verteile ich Last über Replicas?
- Wie deploye ich ohne Downtime?
- Wie verwalte ich Konfigurationen und Secrets?
- Wie skaliere ich automatisch basierend auf Last?

**Antwort: Container Orchestrierung**

---

## Kubernetes: Container Orchestrator

**Was Kubernetes macht:**
- Automatisiertes Deployment und Skalierung
- Self-Healing (startet fehlgeschlagene Container neu)
- Load Balancing und Service Discovery
- Rolling Updates und Rollbacks
- Secret und Konfigurations-Management
- Storage Orchestrierung
- Ressourcen-Optimierung

**"Autopilot für deine Container"**

---

## Kubernetes vs Docker Swarm vs Nomad

**Kubernetes**
- Am beliebtesten (Industriestandard)
- Steile Lernkurve
- Reiches Ökosystem (CNCF)
- Beste Wahl für komplexe Workloads

**Docker Swarm**
- Einfacher zu lernen
- In Docker integriert
- Weniger Feature-reich
- Gut für einfachere Setups

**Nomad**
- Leichtgewichtige Alternative
- Multi-Workload (Container, VMs, Binaries)
- HashiCorp Ökosystem

---

## Wann Kubernetes nutzen

**Gut geeignet für:**
- Microservices Architekturen
- Mehrere Teams/Services
- Bedarf an Auto-Scaling
- High Availability Anforderungen
- Multi-Cloud oder Hybrid-Cloud
- DevOps/GitOps Workflows

**Overkill für:**
- Einfache monolithische Apps
- Kleines Team/einzelner Service
- Minimaler Traffic/Skalierungsbedarf
- Lernprojekte (nutze zuerst Docker Compose)

---

## Sektion 4
### Kubernetes Kernkonzepte

---

## Kubernetes Architektur

**Control Plane** (Master)
- API Server (kubectl spricht hier)
- etcd (verteilte Datenbank)
- Scheduler (weist Pods zu Nodes zu)
- Controller Manager (erhält gewünschten Zustand)

**Worker Nodes**
- kubelet (führt Container aus)
- kube-proxy (Netzwerk)
- Container Runtime (containerd, CRI-O)

---

## Pod: Kleinste Einheit

**Pod** = Ein oder mehrere Container die teilen:
- Netzwerk-Namespace (gleiche IP)
- Storage Volumes
- Lifecycle

**Warum nicht nur Container?**
- Pods ermöglichen Sidecar-Patterns
- Init Container für Setup
- Geteilter Volume-Zugriff

**Beispiel:** Web App + Logging Agent im selben Pod

---

## Pod Beispiel

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

**Pods sind ephemer - sie kommen und gehen**

---

## Deployment: Deklarative Apps

**Deployment** verwaltet:
- ReplicaSet (gewünschte Anzahl von Pods)
- Rolling Updates
- Rollbacks
- Self-Healing

**Du deklarierst "Ich will 3 Replicas", Kubernetes macht es möglich**

---

## Deployment Beispiel

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

## Service: Stabiles Netzwerk

**Problem:** Pods haben dynamische IPs (sie starten neu)

**Lösung:** Service bietet:
- Stabilen DNS-Namen
- Load Balancing über Pods
- Service Discovery

**Typen:**
- ClusterIP (nur intern)
- NodePort (extern via Node-IP)
- LoadBalancer (Cloud-Provider LB)

---

## Service Beispiel

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

**ConfigMap:** Nicht-sensible Konfiguration
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database_url: "postgres://db:5432/myapp"
```

**Secret:** Sensible Daten (base64 kodiert)
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

## Namespace: Virtuelle Cluster

**Namespaces** bieten:
- Ressourcen-Isolation
- RBAC Grenzen
- Ressourcen-Quotas
- Logische Trennung (dev, staging, prod)

**Standard-Namespaces:**
- `default` (deine Apps)
- `kube-system` (Kubernetes Komponenten)
- `kube-public` (öffentlich zugänglich)

---

## Persistent Volumes

**Problem:** Container sind zustandslos

**Lösung:**
- **PersistentVolume (PV):** Storage-Ressource
- **PersistentVolumeClaim (PVC):** Storage-Anforderung
- **StorageClass:** Dynamische Bereitstellung

**Beispiel:** PostgreSQL Datenbank braucht persistenten Storage

---

## Sektion 5
### Hands-on Architektur

---

## Dein Home Lab Setup

**Infrastruktur:**
- Mehrere Nodes (VMs, Bare Metal, Hybrid)
- containerd Runtime
- Kubernetes v1.34

**GitOps mit ArgoCD:**
- Alle Configs in Git
- Deklarative Deployments
- Automatische Synchronisation
- Rollback-Fähigkeiten

---

## Netzwerk: Cilium CNI

**Cilium** bietet:
- Pod Netzwerk (eBPF-basiert)
- Network Policies (Security)
- Load Balancing
- BGP für LoadBalancer IPs
- Service Mesh Fähigkeiten

**Warum Cilium?**
- Hohe Performance
- Erweiterte Observability
- Kubernetes-nativ

---

## Gateway API (Modernes Ingress)

**Gateway API** ersetzt Ingress:

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
- Metriken-Speicherung (Prometheus-kompatibel)
- Hohe Performance, niedrige Ressourcennutzung

**Grafana:**
- Dashboards und Visualisierung
- Alerting

**Promtail + Loki:**
- Log-Aggregation
- Einfaches Querying

---

## Datenbank: CloudNativePG

**High-Availability PostgreSQL:**
- Primary + Replicas
- Automatisches Failover
- Connection Pooling (PgBouncer)
- Backup-Management
- WAL Archivierung

**Operator Pattern:** Erweitert Kubernetes API

---

## Secret Management

**External Secrets Operator:**
- Synchronisiert von 1Password
- Kubernetes Secret wird automatisch erstellt
- Niemals Secrets in Git committen

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

## TLS mit cert-manager

**Automatisches Zertifikats-Management:**
- Let's Encrypt Integration
- Auto-Renewal
- Certificate CRDs

**Beispiel:**
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

**Kombiniere Upstream Helm + lokale Anpassungen:**

```yaml
sources:
- repoURL: https://charts.bitnami.com/bitnami
  chart: postgresql
  targetRevision: 12.1.0
- repoURL: https://github.com/org/repo.git
  path: k8s-sandbox/postgres
  targetRevision: HEAD
```

**Vorteile:** Upstream Updates + lokale Konfiguration

---

## Entwicklungs-Workflow

**1. Änderungen lokal machen**
```bash
kubectl kustomize k8s-sandbox/my-app/
```

**2. Validieren**
```bash
./scripts/check-yaml.sh
```

**3. In Git committen**
```bash
git commit -m "feat(my-app): add feature"
git push
```

**4. ArgoCD synchronisiert automatisch**

---

## Kubernetes Debugging

**Ressourcen anzeigen:**
```bash
kubectl get pods -n namespace
kubectl get svc,deploy,ing -A
```

**Ressource beschreiben:**
```bash
kubectl describe pod pod-name -n namespace
```

**Logs:**
```bash
kubectl logs pod-name -n namespace -f
kubectl logs deploy/app-name --tail=100
```

**In Pod ausführen:**
```bash
kubectl exec -it pod-name -n namespace -- /bin/bash
```

---

## Häufige Probleme & Lösungen

**CrashLoopBackOff**
- Logs prüfen: `kubectl logs pod-name`
- Events prüfen: `kubectl describe pod pod-name`
- Image existiert und ist pullbar verifizieren

**ImagePullBackOff**
- Image-Name und Tag prüfen
- Registry Credentials verifizieren
- imagePullSecrets prüfen

**Pending Pods**
- Unzureichende Ressourcen (CPU/Memory)
- Node Selector Einschränkungen
- PVC nicht gebunden

---

## Best Practices

**Ressourcen-Limits**
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

## Kubernetes Ökosystem (CNCF)

**Beliebte Tools:**
- **ArgoCD** - GitOps Deployments
- **Helm** - Package Manager
- **Prometheus** - Monitoring
- **Cert-Manager** - Zertifikats-Automatisierung
- **External-DNS** - DNS-Automatisierung
- **Velero** - Backup/Restore
- **Kyverno** - Policy Management
- **Crossplane** - Infrastructure as Code

---

## Nächste Schritte

**Weiterlernen:**
- Einfache App zum Cluster deployen
- kubectl Befehle erkunden
- Existierende Apps im Repo studieren
- Mit Skalierung und Updates experimentieren
- StatefulSets für stateful Apps lernen
- In Helm Charts eintauchen

**Ressourcen:**
- kubernetes.io/docs
- CNCF Landscape
- CLAUDE.md in diesem Repo

---

## Fragen?

**Vielen Dank fürs Zuhören!**

Repository: github.com/Starslider/kubernetes-demo

Lass uns deine Kubernetes-Journey besprechen
