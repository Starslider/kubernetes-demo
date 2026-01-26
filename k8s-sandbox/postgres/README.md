# CloudNativePG PostgreSQL

This folder contains the CloudNativePG operator deployment and a PostgreSQL cluster configuration.

## Components

- **CloudNativePG Operator**: Deployed via Helm chart from `https://cloudnative-pg.github.io/charts` (v0.27.0)
- **PostgreSQL Cluster**: 3-instance HA cluster with streaming replication
- **PgBouncer Pooler**: Connection pooler for efficient connection management

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   cnpg-system namespace                      │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐                                        │
│  │  CNPG Operator  │ ← Manages PostgreSQL clusters          │
│  └────────┬────────┘                                        │
└───────────│─────────────────────────────────────────────────┘
            │
            ▼
┌─────────────────────────────────────────────────────────────┐
│                    postgres namespace                        │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────┐    │
│  │              postgres-cluster                        │    │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐             │    │
│  │  │Primary  │  │Replica-1│  │Replica-2│             │    │
│  │  │  (rw)   │──│  (ro)   │──│  (ro)   │             │    │
│  │  │ :5432   │  │ :5432   │  │ :5432   │             │    │
│  │  └─────────┘  └─────────┘  └─────────┘             │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              PgBouncer Pooler                        │    │
│  │  ┌─────────────┐  ┌─────────────┐                   │    │
│  │  │  Pooler-0   │  │  Pooler-1   │                   │    │
│  │  │   :5432     │  │   :5432     │                   │    │
│  │  └─────────────┘  └─────────────┘                   │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## Connecting to PostgreSQL

### Services

CloudNativePG creates several services:

```bash
# Read-write (primary only)
postgres-cluster-rw.postgres.svc.cluster.local:5432

# Read-only (replicas, load balanced)
postgres-cluster-ro.postgres.svc.cluster.local:5432

# Any instance (for monitoring)
postgres-cluster-r.postgres.svc.cluster.local:5432

# PgBouncer pooler (recommended for applications)
postgres-cluster-pooler.postgres.svc.cluster.local:5432
```

### Getting Credentials

The operator creates a secret with credentials:

```bash
# Get the app user password
kubectl get secret postgres-cluster-app -n postgres -o jsonpath='{.data.password}' | base64 -d

# Get the connection URI
kubectl get secret postgres-cluster-app -n postgres -o jsonpath='{.data.uri}' | base64 -d
```

### Testing Connection

```bash
# Port forward to the primary
kubectl port-forward svc/postgres-cluster-rw -n postgres 5432:5432

# Connect with psql
psql -h localhost -U app -d app
```

## Creating Additional Databases

You can create additional databases using SQL or by modifying the cluster spec:

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: postgres-cluster
  namespace: postgres
spec:
  bootstrap:
    initdb:
      database: app
      owner: app
      postInitSQL:
        - CREATE DATABASE mydb;
        - CREATE USER myuser WITH PASSWORD 'mypassword';
        - GRANT ALL PRIVILEGES ON DATABASE mydb TO myuser;
```

## Monitoring

Enable monitoring by setting `enablePodMonitor: true` in the cluster spec. This creates PodMonitor resources for Prometheus/VictoriaMetrics.

## Backups

CloudNativePG supports backups to S3, Azure Blob, or GCS. Configure backup destination:

```yaml
spec:
  backup:
    barmanObjectStore:
      destinationPath: s3://my-bucket/backups
      s3Credentials:
        accessKeyId:
          name: s3-creds
          key: ACCESS_KEY_ID
        secretAccessKey:
          name: s3-creds
          key: SECRET_ACCESS_KEY
    retentionPolicy: "30d"
```

## Resources

- [CloudNativePG Documentation](https://cloudnative-pg.io/documentation/)
- [CloudNativePG GitHub](https://github.com/cloudnative-pg/cloudnative-pg)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
