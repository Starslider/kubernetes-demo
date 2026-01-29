# Kubernetes Workshop
## Kern-Architektur und Cloud Native Konzepte

KCNA-orientierte Schulung

---

## Was wir heute behandeln

- Container-Grundlagen
- Kubernetes Architektur Deep Dive
- Kubernetes Kernkonzepte
- Cloud Native Patterns
- Observability, Security & Autoscaling

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
### Kubernetes Architektur Deep Dive

---

## Kubernetes: Verteiltes System

**Kubernetes ist ein verteiltes System** das über mehrere Nodes läuft

**Grundprinzipien:**
- Deklarative Konfiguration (gewünschter Zustand)
- Controller gleichen tatsächlichen vs gewünschten Zustand ab
- API-getriebene Architektur
- Eventually Consistent
- Hochverfügbar und skalierbar

**Du deklarierst was du willst, Kubernetes findet heraus wie**

---

## Control Plane Komponenten

**API Server** (`kube-apiserver`)
- Zentrale Hub für alle Cluster-Kommunikation
- RESTful API (kubectl, Controller, Operatoren sprechen hier)
- Authentifizierungs- und Autorisierungs-Gateway
- Einzige Komponente die mit etcd spricht
- Horizontal skalierbar

**Wichtig:** Alles in Kubernetes läuft über den API Server

---

## Control Plane: etcd

**etcd** - Verteilter Key-Value Store
- Speichert gesamten Cluster-Zustand
- Single Source of Truth
- Stark konsistent (Raft Consensus)
- Watches für Änderungen (event-driven)

**Was gespeichert wird:**
- Alle Ressourcen-Definitionen (Pods, Services, etc.)
- Cluster-Konfiguration
- Secrets, ConfigMaps
- Aktueller vs gewünschter Zustand

**Kritisch:** Ohne etcd hat dein Cluster kein Gedächtnis

---

## Control Plane: Scheduler

**Scheduler** (`kube-scheduler`)
- Überwacht neu erstellte Pods ohne zugewiesenen Node
- Wählt optimalen Node für jeden Pod
- Startet Pod NICHT (kubelet macht das)

**Scheduling-Faktoren:**
- Ressourcen-Anforderungen (CPU, Memory)
- Node-Selektoren und Affinity-Regeln
- Taints und Tolerations
- Pod Topology Spread Constraints
- Daten-Lokalität

---

## Control Plane: Controller Manager

**Controller Manager** (`kube-controller-manager`)
- Führt mehrere Controller in einem Prozess aus
- Jeder Controller überwacht spezifische Ressourcen
- Reconciliation Loops (beobachten → vergleichen → handeln)

**Eingebaute Controller:**
- Deployment Controller (verwaltet ReplicaSets)
- ReplicaSet Controller (erhält Pod-Replicas)
- Node Controller (überwacht Node-Gesundheit)
- Service Controller (verwaltet Cloud Load Balancer)
- Job Controller (führt Pods bis zur Vollendung aus)

**Pattern:** Gewünschten Zustand überwachen → sicherstellen dass aktueller Zustand passt

---

## Control Plane: Cloud Controller Manager

**Cloud Controller Manager** (optional)
- Interagiert mit Cloud Provider APIs
- Verwaltet Cloud-spezifische Ressourcen
- Entkoppelt Cloud-Logik vom Kubernetes-Kern

**Cloud Controller:**
- Node Controller (verifiziert Nodes mit Cloud Provider)
- Route Controller (richtet Netzwerk-Routen ein)
- Service Controller (erstellt Cloud Load Balancer)
- Volume Controller (erstellt/hängt Cloud-Volumes an)

**Beispiel:** Erstellt AWS ELB wenn Service type LoadBalancer erstellt wird

---

## Worker Node Komponenten

**kubelet** - Node Agent
- Läuft auf jedem Worker Node
- Stellt sicher dass Container in Pods laufen
- Kommuniziert mit API Server
- Meldet Node- und Pod-Status
- Führt Pod Lifecycle Hooks aus
- Mountet Volumes

**Wichtig:** kubelet ist der "Worker" der tatsächlich Container verwaltet

---

## Worker Node: Container Runtime

**Container Runtime** - Führt Container aus
- Kubernetes nutzt Container Runtime Interface (CRI)
- Beliebte Runtimes: containerd, CRI-O, Docker (deprecated)

**Was sie macht:**
- Zieht Container Images aus Registries
- Entpackt Images auf Disk
- Startet/stoppt Container
- Verwaltet Container Lifecycle

**containerd ist heute die häufigste Runtime**

---

## Worker Node: kube-proxy

**kube-proxy** - Netzwerk-Proxy
- Läuft auf jedem Node
- Pflegt Netzwerk-Regeln für Services
- Implementiert Service-Abstraktion (ClusterIP, NodePort)

**Modi:**
- **iptables** (Standard) - Erstellt iptables-Regeln
- **ipvs** (bessere Performance) - Nutzt Linux IPVS
- **userspace** (Legacy)

**Wichtig:** Ermöglicht Pod-zu-Pod und Service-zu-Pod Netzwerk

---

## Kubernetes Netzwerk-Modell

**Kubernetes Netzwerk-Anforderungen:**
1. Alle Pods können ohne NAT kommunizieren
2. Alle Nodes können mit allen Pods kommunizieren
3. Pod sieht seine eigene IP (kein NAT aus Pod-Perspektive)

**Implementiert durch CNI (Container Network Interface) Plugins:**
- Calico, Cilium, Flannel, Weave, etc.
- Jedes mit unterschiedlichen Features und Performance

**Ergebnis:** Flaches Netzwerk wo jeder Pod eine eindeutige IP hat

---

## Kernkonzepte: Pods

**Pod** - Kleinste deploybare Einheit
- Ein oder mehrere Container die teilen:
  - Netzwerk-Namespace (gleiches localhost)
  - IPC-Namespace
  - Storage Volumes
- Atomare Scheduling-Einheit

**Wann mehrere Container in einem Pod:**
- Sidecar-Pattern (Logging, Proxies)
- Adapter-Pattern (Output normalisieren)
- Ambassador-Pattern (Proxy zu externen Services)

**Pods sind Cattle, nicht Pets - sie sind ephemer**

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

## Kernkonzepte: ReplicaSet

**ReplicaSet** - Erhält Pod-Replicas
- Stellt sicher dass spezifizierte Anzahl von Pod-Replicas läuft
- Erstellt/löscht Pods um gewünschte Anzahl zu erreichen
- Identifiziert durch Selector-Labels

**Normalerweise NICHT direkt erstellt:**
- Deployments verwalten ReplicaSets
- ReplicaSets verwalten Pods
- Du verwaltest Deployments

**Deployment → ReplicaSet → Pods**

---

## Kernkonzepte: Deployment

**Deployment** - Deklarative Updates für Pods
- Erstellt und verwaltet ReplicaSets
- Rolling Updates (Zero-Downtime Deployments)
- Rollback zu vorherigen Versionen
- Deployments pausieren und fortsetzen
- Hoch- und runterskalieren

**Update-Strategien:**
- **RollingUpdate** (Standard) - Schrittweiser Austausch
- **Recreate** - Alle Pods löschen dann neue erstellen

**Deployment ist dein Haupt-Workload-Controller**

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

## Kernkonzepte: StatefulSet

**StatefulSet** - Für stateful Anwendungen
- Stabile, eindeutige Netzwerk-Identifikatoren
- Stabiler, persistenter Storage
- Geordnetes, schrittweises Deployment und Skalierung
- Geordnete, automatisierte Rolling Updates

**Anwendungsfälle:**
- Datenbanken (PostgreSQL, MySQL, MongoDB)
- Message Queues (Kafka, RabbitMQ)
- Verteilte Systeme die stabile Identität benötigen

**Pods bekommen vorhersagbare Namen:** `app-0`, `app-1`, `app-2`

---

## Kernkonzepte: DaemonSet

**DaemonSet** - Läuft auf allen (oder einigen) Nodes
- Stellt sicher dass eine Kopie eines Pods auf jedem Node läuft
- Neue Nodes bekommen automatisch den Pod
- Nützlich für Node-Level Operationen

**Anwendungsfälle:**
- Log-Sammlung (Fluentd, Promtail)
- Monitoring-Agenten (Node Exporter)
- Netzwerk-Plugins (CNI-Agenten)
- Storage-Daemons

**Beispiel:** Cilium CNI läuft als DaemonSet

---

## Kernkonzepte: Job & CronJob

**Job** - Führt Pods bis zur Vollendung aus
- Stellt sicher dass spezifizierte Anzahl erfolgreich abgeschlossen wird
- Neustarts bei Fehler
- Parallele Ausführung unterstützt

**CronJob** - Führt Jobs nach Zeitplan aus
- Cron-Syntax für Planung
- Erstellt Jobs zu spezifizierten Zeiten

**Anwendungsfälle:**
- Batch-Verarbeitung
- Datenbank-Migrationen
- Backups
- Periodische Aufräumaufgaben

---

## Kernkonzepte: Services

**Problem:** Pods haben ephemere IPs

**Lösung: Service** - Stabile Netzwerk-Abstraktion
- Stabile ClusterIP (virtuelle IP)
- DNS-Name: `<service>.<namespace>.svc.cluster.local`
- Load Balancing über Pod-Replicas
- Selector-basiert (zielt auf Pods via Labels)

**Services bieten Service Discovery und Load Balancing**

---

## Service-Typen

**ClusterIP** (Standard)
- Nur innerhalb des Clusters erreichbar
- Virtuelle IP im Cluster-Netzwerk
- Häufigster Typ für interne Kommunikation

**NodePort**
- Exponiert Service auf jedem Node's IP mit statischem Port
- Bereich: 30000-32767
- Von außen erreichbar: `<NodeIP>:<NodePort>`

**LoadBalancer**
- Erstellt externen Load Balancer (Cloud Provider)
- Bekommt automatisch externe IP
- Baut auf NodePort auf

**ExternalName**
- Mappt Service zu DNS-Namen (CNAME)
- Kein Proxying involviert

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
    app: nginx  # Zielt auf Pods mit diesem Label
  ports:
  - protocol: TCP
    port: 80          # Service-Port
    targetPort: 8080  # Container-Port
```

**DNS:** `nginx-service.default.svc.cluster.local`

---

## Ingress und Gateway API

**Ingress** - HTTP/HTTPS Routing
- Layer 7 Load Balancing
- Host- und pfad-basiertes Routing
- TLS-Terminierung
- Benötigt Ingress Controller (nginx, Traefik, etc.)

**Gateway API** (neuer, besser)
- Nachfolger von Ingress
- Ausdrucksstärker und erweiterbarer
- Rollenorientiertes Design
- Mehrere Ressourcen-Typen (Gateway, HTTPRoute, etc.)

**Nutze für Exposition mehrerer HTTP-Services mit Routing-Regeln**

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

## Kernkonzepte: Storage

**Volumes** - Pod-Level Storage
- Gebunden an Pod-Lifecycle
- Geteilt zwischen Containern im selben Pod
- Typen: emptyDir, hostPath, configMap, secret

**PersistentVolume (PV)** - Cluster-Level Storage-Ressource
- Unabhängig vom Pod-Lifecycle
- Bereitgestellt von Admin oder dynamisch
- Zugriffsmodi: ReadWriteOnce, ReadOnlyMany, ReadWriteMany

**PersistentVolumeClaim (PVC)** - Storage-Anforderung
- Benutzer fordert Storage mit bestimmter Größe und Zugriffsmodus an
- Bindet an verfügbares PV

**StorageClass** - Dynamische Bereitstellung
- Definiert "Klassen" von Storage (schnelles SSD, langsames HDD, etc.)
- Automatische PV-Erstellung wenn PVC erstellt wird

---

## Storage Beispiel

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
# In Pod-Spec:
volumes:
- name: postgres-storage
  persistentVolumeClaim:
    claimName: postgres-pvc
```

---

## Labels und Selektoren

**Labels** - Key-Value Paare an Objekten
- Verwendet für Organisation und Selektion
- Mehrere Labels pro Objekt
- Beispiele: `app=nginx`, `env=prod`, `tier=frontend`

**Selektoren** - Objekte via Labels abfragen
- **Equality-based:** `app=nginx`, `env!=dev`
- **Set-based:** `env in (prod, staging)`, `tier notin (cache)`

**Anwendungsfälle:**
- Services selektieren Pods: `selector: app=nginx`
- Deployments matchen Pods: `matchLabels: app=nginx`
- kubectl: `kubectl get pods -l app=nginx`

**Labels verbinden Kubernetes-Ressourcen miteinander**

---

## Annotations vs Labels

**Labels:**
- Verwendet für Selektion und Gruppierung
- Max 63 Zeichen
- Muss gültige DNS-Subdomain sein
- Verwendet von Kubernetes-Selektoren

**Annotations:**
- Speichert beliebige Metadaten
- Keine Größenlimits (innerhalb vernünftiger Grenzen)
- Nicht für Selektion verwendet
- Dokumentation, Tool-Konfiguration

**Beispiel-Annotations:**
```yaml
annotations:
  prometheus.io/scrape: "true"
  kubernetes.io/change-cause: "Update auf v2.0"
  description: "Produktions-Datenbank"
```

---

## Sektion 5
### Cloud Native Patterns und KCNA Themen

---

## Cloud Native Architektur

**CNCF Definition:**
Cloud Native Technologien befähigen Organisationen, skalierbare Anwendungen in modernen, dynamischen Umgebungen wie public, private und hybrid Clouds zu bauen und zu betreiben.

**Hauptmerkmale:**
- Containerisierte Workloads
- Dynamisch orchestriert
- Microservices-orientiert
- Deklarative APIs
- Für Automatisierung entwickelt

**Cloud Native ≠ in der Cloud laufen (es geht um den Ansatz)**

---

## Microservices vs Monolithen

**Monolithische Architektur:**
- Einzelne deploybare Einheit
- Gemeinsame Datenbank
- Enge Kopplung
- Gesamte Anwendung skalieren
- Einfacher zu starten, schwerer zu skalieren

**Microservices-Architektur:**
- Unabhängige Services
- Separate Datenbanken (Daten-Isolation)
- Lose Kopplung via APIs
- Services unabhängig skalieren
- Komplex zu starten, einfacher zu skalieren

**Kubernetes ist exzellent für Microservices-Management**

---

## 12-Factor App Prinzipien

**Kernprinzipien für Cloud Native Apps:**
1. **Codebase** - Eine Codebase in Versionskontrolle
2. **Abhängigkeiten** - Abhängigkeiten explizit deklarieren
3. **Config** - Konfiguration in Umgebung speichern
4. **Backing Services** - Als angehängte Ressourcen behandeln
5. **Build, Release, Run** - Stufen strikt trennen
6. **Prozesse** - Als zustandslose Prozesse ausführen
7. **Port Binding** - Services via Port-Binding exportieren
8. **Concurrency** - Via Prozess-Modell skalieren
9. **Disposability** - Schneller Start und sanftes Herunterfahren
10. **Dev/Prod Parity** - Umgebungen ähnlich halten
11. **Logs** - Logs als Event-Streams behandeln
12. **Admin-Prozesse** - Als einmalige Prozesse ausführen

---

## Observability: Die Drei Säulen

**Metriken** - Numerische Daten über Zeit
- CPU-, Speicher-Nutzung
- Request-Raten, Latenzen
- Fehlerraten
- Tools: Prometheus, VictoriaMetrics

**Logs** - Event-Aufzeichnungen
- Anwendungs-Logs
- System-Logs
- Audit-Logs
- Tools: Loki, Elasticsearch, Fluentd

**Traces** - Request-Flows über Services
- Verteiltes Tracing
- Performance-Engpässe
- Service-Abhängigkeiten
- Tools: Jaeger, Tempo, Zipkin

---

## Prometheus und Metriken

**Prometheus** - Open-Source Monitoring-System
- Pull-basierte Metriken-Sammlung
- Time-Series Datenbank
- PromQL Query-Sprache
- Service Discovery (Kubernetes-Integration)
- Alerting mit AlertManager

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

## Health Checks und Probes

**Liveness Probe** - Lebt der Container?
- Startet Container neu wenn Check fehlschlägt
- Nutze für Deadlock-Erkennung

**Readiness Probe** - Ist Container bereit für Traffic?
- Entfernt Pod von Service-Endpoints wenn Check fehlschlägt
- Nutze für Startzeit, Abhängigkeiten

**Startup Probe** - Ist Container gestartet?
- Deaktiviert Liveness/Readiness bis erfolgreich
- Nutze für langsam startende Container

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

**Security-Schichten:**
1. **Cluster** - RBAC, Network Policies, Pod Security
2. **Container** - Image-Scanning, minimale Images, Non-Root
3. **Netzwerk** - Service Mesh, mTLS, Egress-Kontrolle
4. **Daten** - Verschlüsselung at Rest/Transit, Secret-Management
5. **Code** - Secure Coding, Dependency-Scanning

**Security ist mehrschichtig, nicht ein einzelnes Tool**

---

## RBAC (Role-Based Access Control)

**Kernkomponenten:**
- **ServiceAccount** - Identität für Pods
- **Role** - Set von Berechtigungen (Namespace-scoped)
- **ClusterRole** - Set von Berechtigungen (Cluster-scoped)
- **RoleBinding** - Vergibt Role an Subject
- **ClusterRoleBinding** - Vergibt ClusterRole an Subject

**Beispiel:**
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

**Prinzip der minimalen Berechtigung: Minimale notwendige Rechte vergeben**

---

## Network Policies

**NetworkPolicy** - Kontrolliert Pod-zu-Pod Traffic
- Firewall-Regeln für Pods
- Label-basierte Selektion
- Ingress- und Egress-Regeln
- Benötigt CNI-Plugin-Support (Calico, Cilium, etc.)

**Beispiel: Alles verbieten, spezifisches erlauben**
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

**Drei Ebenen (am wenigsten bis am meisten restriktiv):**

**Privileged** - Uneingeschränkt (keine Restriktionen)

**Baseline** - Minimal restriktiv
- Verhindert bekannte Privilege-Escalations
- Erlaubt Standard-Capabilities

**Restricted** - Stark eingeschränkt (Best Practice)
- Non-Root Container
- Verbietet Privilege Escalation
- Entfernt alle Capabilities
- Read-Only Root-Filesystem

**Durchgesetzt via Pod Security Admission oder externe Tools (Kyverno, OPA)**

---

## Ressourcen-Management: Requests vs Limits

**Requests** - Garantierte Ressourcen
- Vom Scheduler für Platzierung verwendet
- Container bekommt mindestens so viel
- QoS-Klassen-Bestimmung

**Limits** - Maximale Ressourcen
- Container kann das nicht überschreiten
- OOMKilled wenn Memory-Limit überschritten
- CPU gedrosselt wenn CPU-Limit überschritten

**Best Practice:**
```yaml
resources:
  requests:
    cpu: "100m"      # 0.1 CPU Core
    memory: "128Mi"
  limits:
    cpu: "500m"      # 0.5 CPU Core
    memory: "512Mi"
```

**Setze immer Requests und Limits um Noisy Neighbors zu vermeiden**

---

## QoS-Klassen

**Guaranteed** (höchste Priorität)
- Requests = Limits für alle Container
- Am wenigsten wahrscheinlich evicted zu werden

**Burstable** (mittlere Priorität)
- Requests < Limits
- Kann extra Ressourcen nutzen wenn verfügbar

**BestEffort** (niedrigste Priorität)
- Keine Requests oder Limits gesetzt
- Wird zuerst evicted unter Druck

**QoS beeinflusst Scheduling- und Eviction-Verhalten**

---

## Horizontal Pod Autoscaler (HPA)

**HPA** - Skaliert Replica-Anzahl automatisch
- Überwacht Metriken (CPU, Memory, Custom)
- Passt Deployment/StatefulSet Replicas an
- Reconciliation Loop (alle 15 Sekunden)

**Beispiel:**
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

**VPA** - Passt Ressourcen-Requests/Limits automatisch an
- Überwacht tatsächliche Ressourcen-Nutzung
- Aktualisiert Requests/Limits-Empfehlungen
- Kann Änderungen automatisch anwenden (benötigt Pod-Neustart)

**Modi:**
- **Off** - Nur Empfehlungen
- **Initial** - Nur bei Pod-Erstellung setzen
- **Auto** - Laufende Pods updaten (benötigt Neustart)

**Nutze VPA wenn du die richtigen Ressourcen-Werte nicht kennst**

---

## Cluster Autoscaler

**Cluster Autoscaler** - Passt Cluster-Größe an
- Fügt Nodes hinzu wenn Pods nicht geplant werden können
- Entfernt Nodes wenn unterausgelastet
- Benötigt Cloud-Provider-Integration

**Funktioniert mit:**
- AWS Auto Scaling Groups
- GCP Managed Instance Groups
- Azure Virtual Machine Scale Sets

**Vollständiges Autoscaling = HPA + VPA + Cluster Autoscaler**

---

## Application Delivery: GitOps

**GitOps** - Git als Single Source of Truth
- Deklarative Infrastruktur und Anwendungen
- Git-Repository enthält gewünschten Zustand
- Automatisierte Synchronisation zum Cluster
- Versionskontrolle für alles
- Einfacher Rollback (git revert)

**Beliebte Tools:**
- **ArgoCD** - Kubernetes-native GitOps
- **Flux** - GitOps Toolkit
- **Jenkins X** - CI/CD für Kubernetes

**GitOps = Infrastructure as Code + Pull Requests + CI/CD**

---

## Helm: Package Manager

**Helm** - Package Manager für Kubernetes
- Pakete heißen "Charts"
- Templating für Kubernetes-Manifests
- Versions-Management
- Abhängigkeits-Management

**Chart-Struktur:**
```
mychart/
  Chart.yaml       # Chart-Metadaten
  values.yaml      # Standard-Werte
  templates/       # Kubernetes-Manifests
    deployment.yaml
    service.yaml
```

**Helm vereinfacht das Deployment komplexer Anwendungen**

---

## Application Delivery Strategien

**Rolling Update** (Standard)
- Schrittweiser Austausch alter Pods
- Zero Downtime
- Konfigurierbar: max surge und max unavailable

**Blue/Green Deployment**
- Zwei identische Umgebungen (blue und green)
- Traffic sofort umschalten
- Einfacher Rollback
- Benötigt 2x Ressourcen

**Canary Deployment**
- Schrittweise Traffic-Verlagerung zu neuer Version
- Metriken überwachen vor vollständigem Rollout
- Progressive Delivery
- Tools: Flagger, Argo Rollouts

---

## ConfigMaps und Secrets

**ConfigMap** - Nicht-sensible Konfiguration
- Umgebungsvariablen
- Kommandozeilen-Argumente
- Konfigurationsdateien

**Secret** - Sensible Daten
- Base64 kodiert (nicht verschlüsselt!)
- Passwörter, Tokens, Keys
- Sollte at Rest verschlüsselt sein (etcd-Verschlüsselung)

**Best Practice:**
- Externes Secret-Management (Vault, AWS Secrets Manager)
- Tools: External Secrets Operator, Sealed Secrets

```yaml
envFrom:
- configMapRef:
    name: app-config
- secretRef:
    name: app-secrets
```

---

## Kubernetes Debugging

**Essentielle kubectl-Befehle:**
```bash
# Ressourcen anzeigen
kubectl get pods -n namespace -o wide
kubectl get events --sort-by=.metadata.creationTimestamp

# Detaillierte Informationen
kubectl describe pod pod-name -n namespace

# Logs
kubectl logs pod-name -n namespace -f --tail=100
kubectl logs -l app=myapp --all-containers=true

# Befehle ausführen
kubectl exec -it pod-name -n namespace -- /bin/sh

# Port Forwarding
kubectl port-forward svc/myapp 8080:80

# Debug mit ephemeral Container (K8s 1.23+)
kubectl debug pod-name -it --image=busybox
```

---

## Häufige Probleme & Lösungen

**CrashLoopBackOff**
- Anwendung beendet sich sofort
- Logs und Container CMD/ENTRYPOINT prüfen
- Abhängigkeiten-Bereitschaft verifizieren

**ImagePullBackOff**
- Image existiert nicht oder falscher Tag
- Registry-Authentifizierungs-Probleme
- imagePullSecrets prüfen

**Pending Pods**
- Unzureichende Cluster-Ressourcen
- Node Selector/Affinity-Constraints nicht erfüllt
- PVC nicht gebunden oder Storage nicht verfügbar

**OOMKilled (Out of Memory)**
- Container überschritt Memory-Limit
- Memory-Limit erhöhen oder App optimieren
- Auf Memory-Leaks prüfen

---

## CNCF Landscape

**CNCF** (Cloud Native Computing Foundation)
- Heimat von Kubernetes und 100+ Projekten
- Drei Reifegrade: Sandbox, Incubating, Graduated

**Wichtige CNCF-Projekte:**
- **Runtime:** Kubernetes, containerd, CRI-O
- **Orchestrierung:** Helm, Argo, Flux
- **Observability:** Prometheus, Grafana, Jaeger, Fluentd
- **Service Mesh:** Istio, Linkerd, Envoy
- **Security:** Falco, cert-manager, SPIFFE/SPIRE
- **Storage:** Rook, Longhorn, Velero

**landscape.cncf.io - Erkunde 1000+ Tools**

---

## Best Practices Zusammenfassung

**Workloads:**
- Setze immer Ressourcen-Requests und Limits
- Nutze Health-Probes (Liveness, Readiness, Startup)
- Laufe nicht als Root
- Nutze spezifische Image-Tags (nicht `latest`)

**Security:**
- Aktiviere RBAC und folge Least Privilege
- Nutze Network Policies
- Scanne Container-Images
- Verschlüssele Secrets at Rest

**Operations:**
- Nutze GitOps für Deployments
- Implementiere Observability (Metriken, Logs, Traces)
- Plane für Skalierung (HPA, VPA, Cluster Autoscaler)
- Regelmäßige Backups mit Velero o.ä.

---

## Nächste Schritte: KCNA Zertifizierung

**KCNA** (Kubernetes and Cloud Native Associate)
- Einstiegs-Zertifizierung von der CNCF
- Deckt Grundlagen ab die wir heute besprochen haben
- 90-Minuten Prüfung, 60 Fragen
- Online beaufsichtigte Prüfung

**Prüfungsbereiche:**
- Kubernetes Fundamentals (46%)
- Container Orchestration (22%)
- Cloud Native Architecture (16%)
- Cloud Native Observability (8%)
- Cloud Native Application Delivery (8%)

**Dieser Workshop deckte die meisten KCNA-Themen ab!**

---

## Praktische Übung

**Essentielle Praxis:**
1. Lokales Kubernetes aufsetzen (minikube, kind, k3s)
2. Beispiel-Anwendungen deployen
3. Mit kubectl-Befehlen experimentieren
4. Dinge kaputtmachen und reparieren
5. Health-Probes und Ressourcen-Limits implementieren
6. Troubleshooting üben

**Lern-Plattformen:**
- killercoda.com (interaktive K8s-Szenarien)
- kubernetes.io/docs/tutorials
- play-with-k8s.com (temporäre Cluster)

**Praktische Erfahrung ist entscheidend**

---

## Zusätzliche Ressourcen

**Offizielle Dokumentation:**
- kubernetes.io/docs
- cncf.io (CNCF-Projekte)
- landscape.cncf.io (Ökosystem-Überblick)

**Bücher:**
- "Kubernetes Up & Running" (O'Reilly)
- "Cloud Native DevOps with Kubernetes" (O'Reilly)

**Praxis:**
- GitHub-Repos mit Beispiel-Apps
- Helm-Charts für echte Anwendungen
- KCNA Prüfungsvorbereitungs-Ressourcen

**Community:**
- Kubernetes Slack
- CNCF Community-Gruppen

---

## Fragen?

**Vielen Dank fürs Zuhören!**

Repository: github.com/Starslider/kubernetes-demo

Lass uns deine Kubernetes-Journey besprechen
