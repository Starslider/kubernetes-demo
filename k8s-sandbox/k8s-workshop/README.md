# Kubernetes Workshop Slide Deck

A markdown-based presentation covering Docker, containers, and Kubernetes fundamentals for engineering teams.

## Overview

This application serves an interactive slide deck built with [reveal.js](https://revealjs.com/) that presents comprehensive training materials on:

- What is Docker?
- Understanding Containers
- Why Kubernetes?
- Kubernetes Core Concepts
- Hands-on Architecture (based on this repository's setup)

## Architecture

**Markdown-First Approach:**
- Content defined in `slides.md` (easy to edit and maintain)
- reveal.js framework renders markdown as interactive slides
- Static site served by nginx
- Lightweight container (~50MB)

**Stack:**
- Node.js (build-time only) - installs reveal.js
- nginx:alpine - serves static assets
- reveal.js 5.0.4 - presentation framework

## Accessing the Slides

**Production:**
- URL: `https://workshop.dhlabs.org`
- Exposed via Gateway API HTTPRoute
- TLS certificate from cert-manager (Let's Encrypt)

**Local Development:**
```bash
# Test locally with Docker
docker build -t k8s-workshop:test .
docker run -p 8080:80 k8s-workshop:test
# Open http://localhost:8080
```

## Slide Navigation

- **Next Slide:** Right arrow, Space, or click
- **Previous Slide:** Left arrow
- **Overview Mode:** Press `O` or `ESC`
- **Search:** Press `CTRL+SHIFT+F`
- **Speaker Notes:** Press `S`
- **Zoom:** Hold `ALT` (or `CTRL` on Windows) and click
- **Direct Navigation:** Use slide number (e.g., `#/5`)

## Editing Slides

**Content is in `slides.md`**

### Slide Separators

```markdown
---           # New slide (horizontal)
--            # New slide (vertical, creates sub-slides)
Note:         # Speaker notes (hidden from main view)
```

### Formatting

- Standard markdown syntax
- Code blocks with language highlighting
- Tables
- Lists (bulleted and numbered)
- Images: `![alt text](url)`
- Bold: `**text**`
- Emphasis: `*text*`

### Example Slide

```markdown
## My Slide Title

Content here with **bold** and *italic* text.

- Bullet point one
- Bullet point two

\```yaml
apiVersion: v1
kind: Pod
metadata:
  name: example
\```

---
```

## Deployment

**Automatic via GitOps:**

1. Edit `slides.md` with your changes
2. Commit and push to main branch
3. GitHub Actions builds new container image
4. ArgoCD syncs and deploys to cluster

**Manual Build:**
```bash
# Build and push manually
docker build -t ghcr.io/starslider/kubernetes-demo/k8s-workshop:latest .
docker push ghcr.io/starslider/kubernetes-demo/k8s-workshop:latest

# Restart deployment
kubectl rollout restart deployment/k8s-workshop -n k8s-workshop
```

## Container Details

**Image:** `ghcr.io/starslider/kubernetes-demo/k8s-workshop:latest`

**Multi-stage Build:**
1. Builder stage: Node.js installs reveal.js dependencies
2. Final stage: nginx serves static files

**Security Features:**
- Runs as non-root user (UID 1001)
- Read-only root filesystem (except nginx runtime dirs)
- Minimal attack surface (alpine base)
- No unnecessary packages

**Resource Usage:**
- Memory: 64Mi requested, 128Mi limit
- CPU: 50m requested, 100m limit
- Replicas: 2 (for HA)

## Customization

### Changing Theme

Edit `index.html` line 14:
```html
<link rel="stylesheet" href="dist/theme/black.css">
```

Available themes: black, white, league, beige, sky, night, serif, simple, solarized

### Adding Plugins

reveal.js supports many plugins. To add one:

1. Install in Dockerfile: `npm install reveal-plugin-name`
2. Copy to final stage in Dockerfile
3. Import in `index.html`
4. Configure in `Reveal.initialize({ plugins: [...] })`

### Custom Styling

Add CSS to the `<style>` block in `index.html` (lines 18-67)

## Troubleshooting

**Slides not updating after commit:**
```bash
# Check GitHub Actions workflow
gh workflow view "Build Kubernetes Workshop Container"

# Check ArgoCD sync status
kubectl -n argocd get application k8s-workshop

# Force sync
kubectl -n argocd argocd app sync k8s-workshop

# Check pod logs
kubectl logs -n k8s-workshop deployment/k8s-workshop
```

**Container won't start:**
```bash
# Check pod status
kubectl get pods -n k8s-workshop

# Describe pod for events
kubectl describe pod <pod-name> -n k8s-workshop

# Check for image pull errors
kubectl get events -n k8s-workshop --sort-by='.lastTimestamp'
```

**404 errors:**
- Check nginx logs: `kubectl logs -n k8s-workshop deployment/k8s-workshop`
- Verify HTTPRoute: `kubectl get httproute -n ingress`
- Check Gateway: `kubectl get gateway ingress-gateway -n ingress`

## Files

```
k8s-sandbox/k8s-workshop/
├── Dockerfile                    # Multi-stage container build
├── index.html                    # reveal.js configuration
├── slides.md                     # Slide content (EDIT THIS)
├── deployment.yaml               # Kubernetes Deployment
├── service.yaml                  # ClusterIP Service
├── httproute-grant.yaml          # Allow ingress access
├── kustomization.yaml            # Kustomize config
└── README.md                     # This file

k8s-sandbox/ingress/ingress/
└── k8s-workshop-httproute.yaml   # HTTPRoute for external access

k8s-sandbox/apps/
└── k8s-workshop.yaml             # ArgoCD Application

.github/workflows/
└── build-k8s-workshop.yml        # Container build CI/CD
```

## References

- [reveal.js Documentation](https://revealjs.com/)
- [reveal.js Markdown Guide](https://revealjs.com/markdown/)
- [Gateway API Docs](https://gateway-api.sigs.k8s.io/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)

## Future Enhancements

**Potential additions:**
- [ ] Speaker notes with detailed talking points
- [ ] Animated diagrams with reveal.js transitions
- [ ] Interactive demos (embedded terminals)
- [ ] Quiz/assessment slides
- [ ] Multi-language support
- [ ] PDF export functionality
- [ ] Video recordings of presentations
- [ ] Live polls/feedback integration

**Contributing:**
PRs welcome! Follow the commit message convention in `CLAUDE.md`
