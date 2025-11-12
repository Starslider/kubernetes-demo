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

## Alert Suppressions

The following alerts are intentionally suppressed due to expected behavior:

### Control-Plane Component TLS Alerts

**TargetDown for kube-scheduler and kube-controller-manager**
- **Reason**: These control-plane components use TLS certificates valid only for `localhost`/`127.0.0.1`, not for the node IP address.
- **Impact**: Metrics scraping via IP fails with TLS certificate validation errors (expected security behavior).
- **Mitigation**: Control-plane VMAgent with `hostNetwork: true` successfully scrapes these endpoints via localhost.
- **Suppression**: Configured in `vmalertmanager-config.yaml` - routed to 'null' receiver to prevent Discord notifications.

## Usage

Update monitoring configuration, alerts, and dashboards as needed. Changes are automatically applied by ArgoCD.

For manual application:
```bash
kubectl apply -k .
```