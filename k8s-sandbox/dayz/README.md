# DayZ Server Configuration

This directory contains the configuration for a DayZ game server deployment.

## Components

- **configmap.yaml**: Server configuration settings
- **cronjob.yaml**: Scheduled tasks configuration
- **deployment.yaml**: Server deployment configuration
- **kustomization.yaml**: Kustomize configuration
- **pvc.yaml**: Persistent volume claim for server data
- **rbac.yaml**: Role-based access control configuration
- **secrets.yaml**: Sensitive configuration data
- **serviceaccount.yaml**: Service account configuration
- **svc.yaml**: Service configuration

## Features

The DayZ server deployment includes:
- Automated server management
- Persistent storage for game data
- Scheduled maintenance tasks
- Secure configuration management

## Usage

To modify the server configuration:
1. Update the relevant configuration files
2. Let ArgoCD sync the changes or apply manually:
```bash
kubectl apply -k .
```