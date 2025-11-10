# Monitoring Configuration

This directory contains the configuration for the cluster monitoring stack.

**Components Versions**:
- Prometheus: 2.47.1 (Latest stable)
- Grafana: 10.1.5 (Latest stable)
- AlertManager: 0.26.0 (Latest stable)

**GitHub Repositories**:
- [prometheus/prometheus](https://github.com/prometheus/prometheus)
- [grafana/grafana](https://github.com/grafana/grafana)
- [prometheus/alertmanager](https://github.com/prometheus/alertmanager)

**Documentation**:
- [Prometheus Docs](https://prometheus.io/docs/introduction/overview/)
- [Grafana Docs](https://grafana.com/docs/)
- [AlertManager Docs](https://prometheus.io/docs/alerting/latest/alertmanager/)

## Features

The monitoring stack includes:
- Prometheus for metrics collection
- Grafana for visualization
- AlertManager for alerting
- Service monitors for target discovery
- Custom dashboards and alerts

## Usage

Update monitoring configuration, alerts, and dashboards as needed. Changes are automatically applied by ArgoCD.

For manual application:
```bash
kubectl apply -k .
```