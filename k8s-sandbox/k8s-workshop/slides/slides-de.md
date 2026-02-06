# Kubernetes Workshop
## Von Containern zu Cloud Native

Eine Einführung für Einsteiger

---

## Heutige Reise

**Teil 1:** Die Container-Revolution (15 Min)
- Warum Container wichtig sind
- Welches Problem sie lösen

**Teil 2:** Willkommen bei Kubernetes (20 Min)
- Was ist Kubernetes?
- Kernkonzepte einfach erklärt

**Teil 3:** Cloud Native Denken (20 Min)
- Moderne Anwendungsmuster
- Erste Schritte mit Kubernetes

---

## Teil 1
### Die Container-Revolution

---

## Das klassische Problem

**Stell dir vor:**

Dein Entwickler sagt: **"Bei mir funktioniert es!"**

Aber in Production...
- ❌ Anderes Betriebssystem
- ❌ Fehlende Abhängigkeiten
- ❌ Falsche Versionen installiert
- ❌ Andere Konfiguration

**Kommt dir bekannt vor?**

---

## Lösung: Container

Denk an einen Container wie eine **Tiefkühlpizza** 🍕

- **Standardisiert** - Jede Pizza gleich verpackt
- **In sich geschlossen** - Alle Zutaten enthalten
- **Portabel** - Funktioniert in jedem Ofen
- **Isoliert** - Bleibt getrennt von anderem Essen

**Ein Container verpackt deine App + alles was sie braucht**

---

## Was ist in einem Container?

```
📦 Dein Anwendungs-Container
   ├── Dein Anwendungscode
   ├── Runtime (Node.js, Python, Java)
   ├── Bibliotheken und Abhängigkeiten
   ├── Konfigurationsdateien
   └── Umgebungsvariablen
```

**Einmal verpacken, überall ausführen!**

---

## Container vs Traditionell

**Traditionelles Deployment:**
```
Server 1: OS → Viele Apps kämpfen um Ressourcen
Server 2: OS → Verschiedene Versionen, Konflikte
Server 3: OS → "Warum funktioniert das nicht?!"
```

**Mit Containern:**
```
Server 1: OS → 📦📦📦 (isolierte Apps)
Server 2: OS → 📦📦📦 (gleiche Container)
Server 3: OS → 📦📦📦 (vorhersagbar!)
```

**Jeder Container ist isoliert und vorhersagbar**

---

## Warum Entwickler Container lieben

✅ **Konsistenz** - Überall gleich
✅ **Schnell** - Starten in Sekunden
✅ **Leichtgewicht** - Keine vollen VMs
✅ **Isoliert** - Keine Konflikte
✅ **Portabel** - Überall lauffähig

**"Einmal bauen, überall ausführen"**

---

## Die nächste Herausforderung

**Container lösten ein Problem...**
- ✅ Anwendungen verpacken

**Aber schufen neue Fragen:**
- ❓ Was wenn ich 100 Container habe?
- ❓ Was wenn ein Container abstürzt?
- ❓ Wie aktualisiere ich Container?
- ❓ Wie finden Container einander?
- ❓ Wie skaliere ich bei Lastspitzen?

**Wir brauchen einen Orchestrator!**

---

## Teil 2
### Willkommen bei Kubernetes

---

## Was ist Kubernetes?

**Denk an Kubernetes als Betriebssystem für deine Container**

Genau wie das OS deines Laptops:
- Plant Programme
- Überwacht Gesundheit
- Verwaltet Ressourcen
- Handhabt Netzwerk
- Startet Abstürze neu

**Kubernetes macht das für Container, in großem Maßstab**

---

## Das Kubernetes-Versprechen

**Du sagst Kubernetes:**
> "Ich möchte 5 Kopien meiner Web-App laufen haben"

**Kubernetes stellt sicher:**
- ✅ Erstellt 5 Container
- ✅ Verteilt sie über Server
- ✅ Startet bei Absturz neu
- ✅ Verteilt Traffic zwischen ihnen
- ✅ Aktualisiert sie sicher
- ✅ Skaliert sie automatisch

**Du beschreibst was du willst. Kubernetes macht es möglich.**

---

## Analogie aus der echten Welt

**Kubernetes ist wie ein Restaurant-Manager:**

Du (Koch) → "Ich brauche diese Gerichte"

Manager (Kubernetes):
- Weist Aufgaben dem Küchenpersonal zu (Server)
- Überwacht ob Personal arbeitet (Health Checks)
- Ersetzt krankes Personal (startet Container neu)
- Bedient mehr Gäste (skaliert hoch)
- Koordiniert alles reibungslos

---

## Kubernetes Architektur (Einfache Ansicht)

```
┌─────────────────────────────────────┐
│         Control Plane               │
│    (Das Gehirn - Trifft Entsch.)   │
│                                     │
│  • Empfängt deine Anfragen          │
│  • Plant Container                  │
│  • Überwacht alles                  │
└─────────────────────────────────────┘
           ↓ ↓ ↓
┌────────────┐ ┌────────────┐ ┌────────────┐
│  Worker 1  │ │  Worker 2  │ │  Worker 3  │
│            │ │            │ │            │
│   [Pods]   │ │   [Pods]   │ │   [Pods]   │
│            │ │            │ │            │
│  (Führt    │ │  (Führt    │ │  (Führt    │
│ Container  │ │ Container  │ │ Container  │
│    aus)    │ │    aus)    │ │    aus)    │
└────────────┘ └────────────┘ └────────────┘
```

---

## Kernkonzept #1: Pods

**Pod** = Die kleinste Einheit in Kubernetes

Denk daran als **Wrapper um deine Container**

```
┌─────────────────┐
│      Pod        │
│  ┌───────────┐  │
│  │ Container │  │
│  │  (Deine   │  │
│  │   App)    │  │
│  └───────────┘  │
└─────────────────┘
```

**Ein Pod = normalerweise ein Container**

Pods sind temporär - können jederzeit ersetzt werden

---

## Kernkonzept #2: Deployments

**Deployment** = Bauplan für deine App

Du sagst:
```yaml
Ich möchte:
  - 3 Kopien meiner Web-App
  - Mit Image: my-app:v1.0
  - Je 512MB RAM
```

Kubernetes erstellt und verwaltet sie automatisch

**Deployments stellen sicher dass dein gewünschter Zustand erhalten bleibt**

---

## Kernkonzept #3: Services

**Problem:** Pods kommen und gehen, IPs ändern sich

**Lösung: Service** = Stabile Adresse für deine App

```
Internet-Anfrage
      ↓
   Service (stabile Adresse)
      ↓
Verteilt an → 📦 Pod 1
             📦 Pod 2
             📦 Pod 3
```

**Service = Load Balancer + DNS-Name + stabiler Endpunkt**

---

## Alles zusammen

**Beispiel: Web-App betreiben**

1. **Du erstellst:** Deployment (beschreibt deine App)
2. **Kubernetes erstellt:** 3 Pods (deine laufende App)
3. **Du erstellst:** Service (stabiler Zugangspunkt)
4. **Kubernetes kümmert sich um:**
   - Neustart abgestürzter Pods
   - Traffic-Verteilung
   - Rolling Updates
   - Skalierung

**Du verwaltest das "Was", Kubernetes das "Wie"**

---

## Wie du mit Kubernetes sprichst

**kubectl** = Kommandozeilen-Tool

```bash
# Deploye deine App
kubectl apply -f my-app.yaml

# Prüfe ob sie läuft
kubectl get pods

# Siehe deine Services
kubectl get services

# Skaliere auf 5 Kopien
kubectl scale deployment my-app --replicas=5
```

**Einfache Befehle um alles zu steuern**

---

## Echtes Beispiel: Web-App deployen

```yaml
# Sag Kubernetes was du willst
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-website
spec:
  replicas: 3                # 3 Kopien bitte
  template:
    spec:
      containers:
      - name: website
        image: nginx:latest   # Welches Container-Image
```

**Das ist alles! Kubernetes macht den Rest.**

---

## Konfiguration: Der Kubernetes-Weg

**Speichere keine Passwörter in Containern!**

**ConfigMap** - Normale Einstellungen
```yaml
database_host: "db.example.com"
cache_size: "1000"
```

**Secret** - Sensible Daten
```yaml
database_password: "secretpw123"
api_key: "key-abc-xyz"
```

**Kubernetes injiziert diese in deine Container**

---

## Storage: Daten persistent machen

**Denk daran:** Container sind temporär

**Für Daten die überleben müssen:**

```
┌──────────┐    ┌──────────────┐    ┌──────────────┐
│Dein Pod  │───→│ PersistentVC │───→│ Persistent   │
│          │    │   (Claim)    │    │   Volume     │
│  [App]   │    │              │    │  (Storage)   │
└──────────┘    └──────────────┘    └──────────────┘
 (temporär)      (Anforderung)       (echte Disk)
```

**So funktioniert es:**
1. **Persistent Volume (PV)** - Tatsächliche Storage-Ressource
2. **PersistentVolumeClaim (PVC)** - Anforderung für Storage
3. **Pod** - Nutzt den PVC für Zugriff auf Storage

**Nutze für Datenbanken, hochgeladene Dateien, etc.**

---

## Teil 3
### Cloud Native Denken

---

## Was ist "Cloud Native"?

**Cloud Native = Apps für moderne Infrastruktur entwickeln**

**Traditionelle App:**
- Großer Monolith
- Läuft auf einem Server
- Schwer zu aktualisieren
- Skaliert durch größere Server

**Cloud Native App:**
- In kleine Services aufgeteilt
- Läuft auf vielen Containern
- Einfach zu aktualisieren
- Skaliert durch mehr Container

---

## Microservices erklärt

**Monolith:**
```
┌───────────────────────┐
│   Eine große App      │
│  ┌─────────────────┐  │
│  │ Benutzer-Login  │  │
│  │ Produktkatalog  │  │
│  │ Warenkorb       │  │
│  │ Zahlung         │  │
│  └─────────────────┘  │
└───────────────────────┘
```

**Microservices:**
```
📦 Login-Service  →  📦 Katalog-Service
                 ↘              ↓
                   📦 Warenkorb-Service
                              ↓
                    📦 Zahlungs-Service
```

**Jeder Service = unabhängig, skalierbar, aktualisierbar**

---

## Warum Microservices + Kubernetes?

**Vorteile:**

1. **Skaliere was du brauchst**
   - Black Friday? Skaliere Zahlungs-Service
   - Normaler Tag? Skaliere runter

2. **Sicher aktualisieren**
   - Warenkorb updaten ohne Zahlung zu berühren
   - Rollback bei Problemen

3. **Team-Autonomie**
   - Verschiedene Teams betreuen verschiedene Services
   - Unabhängiges Deployment

4. **Zuverlässigkeit**
   - Ein Service fällt aus? Andere laufen weiter

---

## Observability: Apps überwachen

**Drei Säulen der Observability:**

**1. Metriken** 📊
- "CPU ist bei 80%"
- "Antwortzeit: 200ms"
- Tools: Prometheus, Grafana

**2. Logs** 📝
- "Benutzer Max hat sich eingeloggt"
- "Fehler: Datenbank-Timeout"
- Tools: Loki, Elasticsearch

**3. Traces** 🔍
- "Request ging: API → Datenbank → Cache"
- Finde langsame Operationen
- Tools: Jaeger, Tempo

---

## Health Checks: Am Leben bleiben

**Kubernetes prüft ständig deine Container:**

**Liveness:** "Lebst du noch?"
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
```
→ Bei Fehler: Container neustarten

**Readiness:** "Bereit für Traffic?"
```yaml
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
```
→ Bei Fehler: Kein Traffic senden

---

## Auto-Scaling: Wachsen und Schrumpfen

**Horizontal Pod Autoscaler (HPA)**

```
Normal:       📦📦     (2 Pods)

Lastspitze:   📦📦📦📦📦 (5 Pods)

Zurück:       📦📦     (2 Pods)
```

**Kubernetes überwacht CPU/Memory und skaliert automatisch**

**Du setzt Min/Max, Kubernetes passt basierend auf Last an**

---

## Security Grundlagen

**Best Practices:**

1. **Nicht als Root laufen**
   ```yaml
   securityContext:
     runAsNonRoot: true
   ```

2. **Limitiere was Container tun können**
   ```yaml
   securityContext:
     allowPrivilegeEscalation: false
   ```

3. **Nutze Secrets richtig**
   - Nie im Code
   - Nie in Images
   - Nutze Kubernetes Secrets

4. **Network Policies**
   - Kontrolliere wer mit wem sprechen kann

---

## Deployment-Strategien

**Rolling Update** (Standard)
```
v1: 📦📦📦  →  v1: 📦📦⚪  →  v1: 📦⚪⚪  →  v2: ⚪⚪⚪
v2:         →  v2: ⚪📦   →  v2: ⚪📦📦  →  (fertig)
```
Schrittweiser Austausch, keine Downtime

**Blue/Green**
```
Blue (v1):  📦📦📦  ←  Aller Traffic
Green (v2): 📦📦📦  (bereit)

Wechsel! →

Blue (v1):  📦📦📦  (kann zurück)
Green (v2): 📦📦📦  ←  Aller Traffic
```

---

## GitOps: Infrastructure as Code

**Traditionell:**
```
Entwickler → Manuelle Befehle → Production
             kubectl apply...
```

**GitOps:**
```
Entwickler → Git Commit → Automatisches Deployment
             (alles versioniert)
```

**Vorteile:**
- Versionskontrolle für Infrastruktur
- Einfacher Rollback (git revert)
- Audit-Trail (wer hat was geändert)
- Automatisiert und konsistent

**Tool: ArgoCD, Flux**

---

## Häufige kubectl Befehle

```bash
# Siehe was läuft
kubectl get pods
kubectl get services
kubectl get deployments

# Details anzeigen
kubectl describe pod my-pod

# Logs ansehen
kubectl logs my-pod

# Container zugreifen
kubectl exec -it my-pod -- sh

# Ressourcen löschen
kubectl delete pod my-pod
```

**Das sind 90% dessen was du täglich nutzt**

---

## Troubleshooting 101

**Pod startet nicht?**
```bash
kubectl describe pod my-pod
# Schau im Events-Bereich
```

**App abgestürzt?**
```bash
kubectl logs my-pod
# Prüfe Fehlermeldungen
```

**App nicht erreichbar?**
```bash
kubectl get services
# Überprüfe Service-Konfiguration
```

**Meiste Probleme sind in: Image-Name, Config, oder Ressourcen**

---

## Paket-Management: Helm

**Helm** = Paketmanager für Kubernetes

Denk daran wie **apt, yum, oder npm** für Kubernetes

```yaml
# Statt 20+ YAML-Dateien zu verwalten
helm install my-app stable/wordpress

# Updates leicht gemacht
helm upgrade my-app stable/wordpress --version 2.0

# Einfacher Rollback
helm rollback my-app
```

**Vorteile:**
- Wiederverwendbare Anwendungs-Templates
- Versionsverwaltung
- Einfache Updates und Rollbacks
- Pakete teilen über Helm Charts

---

## Konfigurations-Management: Kustomize

**Kustomize** = Template-freie Anpassung

**Das Problem:** Gleiche App, verschiedene Umgebungen

```
Basis-Konfiguration (gemeinsam)
    ↓
├─> Dev (kleine Ressourcen, Debug aktiv)
├─> Staging (mittlere Ressourcen)
└─> Production (große Ressourcen, Monitoring)
```

**So funktioniert es:**
```yaml
# Basis-Deployment
resources:
  - deployment.yaml

# Production-Overlay
resources:
  - ../../base
patches:
  - replica-count.yaml
  - resource-limits.yaml
```

**In kubectl integriert!**

---

## GitOps mit ArgoCD

**ArgoCD** = Continuous Delivery für Kubernetes

**Traditionelle CI/CD:**
```
Git → CI Pipeline → kubectl apply → Cluster
      (Push-Modell - Pipeline hat Cluster-Zugriff)
```

**ArgoCD (GitOps):**
```
Git → ArgoCD überwacht → Synchronisiert automatisch
      (Pull-Modell - Cluster holt Änderungen)
```

**Hauptfunktionen:**
- 🔄 Automatische Sync von Git
- 👁️ Visuelles Dashboard für Deployments
- 🔙 Einfacher Rollback zu jedem Git Commit
- 🎯 Multi-Cluster-Management
- 📊 Health-Monitoring

**Dein Git-Repo wird zur Single Source of Truth**

---

## Lernressourcen

**Kostenlose Ressourcen:**
- **kubernetes.io/docs** - Offizielle Docs
- **killercoda.com** - Interaktive Labs
- **play-with-k8s.com** - Kostenlose Sandbox

**Bücher:**
- "Kubernetes Up & Running"
- "The Kubernetes Book"

**Praxis:**
1. Deploye einfache Apps lokal
2. Mach Dinge absichtlich kaputt
3. Repariere sie
4. Wiederhole!

**Hands-on ist der beste Weg zu lernen**

---

## Das Kubernetes Ökosystem (CNCF)

**Cloud Native Computing Foundation (CNCF)**

Über 1000+ Tools im Ökosystem:

**Haupt-Kategorien:**
- **Container Runtime:** containerd, CRI-O
- **Orchestrierung:** Kubernetes, Helm
- **Observability:** Prometheus, Grafana
- **Service Mesh:** Istio, Linkerd
- **Security:** Falco, cert-manager
- **Storage:** Rook, Longhorn

**Kubernetes ist nur das Fundament!**

---

## Wichtigste Erkenntnisse

1. **Container** = Portable, isolierte Anwendungspakete
2. **Kubernetes** = Automatisiert Container-Management im großen Maßstab
3. **Deklarativ** = Du sagst was, K8s findet heraus wie
4. **Cloud Native** = Moderner Weg skalierbare Apps zu bauen
5. **Starte einfach** = Lerne Grundlagen, dann erweitere

**Versuche nicht alles auf einmal zu lernen!**

**Meistere zuerst die Grundlagen.**

---

## Deine nächsten Schritte

**Woche 1-2:** Grundlagen
- Richte lokalen Cluster ein
- Übe mit kubectl
- Verstehe Kern-Ressourcen

**Woche 3-4:** Kernkonzepte
- Meistere Deployments, Services, ConfigMaps
- Arbeite mit Pods und ReplicaSets
- Übe Skalierung und Updates

**Monat 2:** Fortgeschrittene Themen
- Storage und Networking
- Security Best Practices
- Monitoring und Observability

**Monat 3:** Echte Projekte
- Baue Multi-Service-Anwendungen
- Implementiere GitOps mit ArgoCD
- Nutze Helm und Kustomize

---

## Fragen?

**Danke für deine Zeit!**

**Denk daran:**
- Fang klein an
- Übe praktisch
- Die Community hilft
- Es ist okay nicht alles zu wissen

**Ressourcen:**
- kubernetes.io/docs
- CNCF Slack
- GitHub: github.com/Starslider/kubernetes-demo

**Lass uns deine Fragen besprechen!**
