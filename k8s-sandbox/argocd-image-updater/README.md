# Argo CD Image Updater

This directory contains configuration for Argo CD Image Updater, which automatically tracks container image updates.

## Overview

Argo CD Image Updater monitors container registries for new images and updates ArgoCD Applications when new versions are available.

## Features

- **Automatic Image Tracking**: Monitors GHCR (GitHub Container Registry) for new image tags
- **Update Strategies**: Supports various strategies (latest, semver, digest)
- **Write-Back Methods**: Can update Git or just ArgoCD directly
- **Multiple Registries**: Configured to work with GitHub Container Registry

## Configuration

### Registry Configuration

The registry configuration is in `configmap.yaml`:
- **GHCR** (ghcr.io): GitHub Container Registry with authentication

### Authentication

Authentication is handled via External Secrets Operator:
- Secret: `github-registry-creds` in `argocd` namespace
- Source: 1Password `github-packages-token`
- Format: Personal Access Token (PAT) with `read:packages` scope

## Enabling Image Updates for Applications

To enable image tracking for an application, add annotations to the ArgoCD Application manifest:

```yaml
metadata:
  annotations:
    # List of images to track (alias=image)
    argocd-image-updater.argoproj.io/image-list: myapp=ghcr.io/org/repo/image

    # Update strategy (latest, semver, digest, name)
    argocd-image-updater.argoproj.io/myapp.update-strategy: latest

    # Write-back method (git or argocd)
    argocd-image-updater.argoproj.io/write-back-method: argocd

    # Optional: Allow specific tag patterns
    argocd-image-updater.argoproj.io/myapp.allow-tags: regexp:^(latest|main-[a-f0-9]{7})$

    # Optional: Pull secret for private registries
    argocd-image-updater.argoproj.io/myapp.pull-secret: pullsecret:argocd/github-registry-creds
```

### Update Strategies

- **latest**: Always use the `latest` tag or most recent timestamp
- **semver**: Follow semantic versioning (e.g., `v1.2.3`)
- **digest**: Track by image digest/SHA
- **name**: Lexicographic sorting of tags

### Write-Back Methods

- **argocd**: Update image in ArgoCD directly (faster, no Git commits)
- **git**: Commit changes back to Git repository (full GitOps)

## Example: k8s-workshop

The k8s-workshop application uses image updater with these settings:

```yaml
annotations:
  argocd-image-updater.argoproj.io/image-list: workshop=ghcr.io/starslider/kubernetes-demo/k8s-workshop
  argocd-image-updater.argoproj.io/workshop.update-strategy: latest
  argocd-image-updater.argoproj.io/write-back-method: argocd
  argocd-image-updater.argoproj.io/workshop.allow-tags: regexp:^(latest|main-[a-f0-9]{7})$
```

This tracks:
- The `latest` tag
- Tags matching pattern `main-<7-char-sha>` (from CI builds)
- Updates directly in ArgoCD without Git commits

## Viewing Image Updates

In ArgoCD UI:
1. Navigate to the application (e.g., k8s-workshop)
2. Check the application status
3. Look for image update annotations
4. View the current image and available updates

In CLI:
```bash
# View image updater logs
kubectl logs -n argocd deployment/argocd-image-updater -f

# Check application for image updates
kubectl get app k8s-workshop -n argocd -o jsonpath='{.metadata.annotations}'
```

## Troubleshooting

### Images not updating

1. Check image updater logs:
   ```bash
   kubectl logs -n argocd deployment/argocd-image-updater
   ```

2. Verify registry credentials:
   ```bash
   kubectl get secret github-registry-creds -n argocd
   ```

3. Check application annotations:
   ```bash
   kubectl get app k8s-workshop -n argocd -o yaml
   ```

### Authentication issues

Ensure the GitHub PAT (Personal Access Token) has:
- `read:packages` scope for reading from GHCR
- Valid expiration date
- Proper access to the repository

## References

- [Argo CD Image Updater Docs](https://argocd-image-updater.readthedocs.io/)
- [Configuration Options](https://argocd-image-updater.readthedocs.io/en/stable/configuration/images/)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
