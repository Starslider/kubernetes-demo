# Strimzi Kafka Operator

This folder contains the Strimzi Kafka operator deployment and a sample Kafka cluster configuration.

## Components

- **Strimzi Operator**: Deployed via Helm chart from `https://strimzi.io/charts/` (v0.50.0)
- **Kafka Cluster**: 3-broker + 3-controller Kafka 4.1.1 cluster using KRaft (no ZooKeeper)
- **Demo Topic**: Sample topic with 3 partitions and replication factor of 3

## Architecture

Kafka 4.x uses **KRaft mode** (Kafka Raft) instead of ZooKeeper for metadata management.

```
┌─────────────────────────────────────────────────────────────┐
│                     strimzi namespace                        │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐                                        │
│  │ Strimzi Operator│ ← Manages Kafka CRs                    │
│  └────────┬────────┘                                        │
│           │                                                  │
│           ▼                                                  │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              kafka-cluster (KRaft)                   │    │
│  │                                                      │    │
│  │  Controllers (metadata quorum):                      │    │
│  │  ┌────────────┐ ┌────────────┐ ┌────────────┐       │    │
│  │  │Controller-0│ │Controller-1│ │Controller-2│       │    │
│  │  └────────────┘ └────────────┘ └────────────┘       │    │
│  │                                                      │    │
│  │  Brokers (data):                                     │    │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐             │    │
│  │  │Broker-0 │  │Broker-1 │  │Broker-2 │             │    │
│  │  │:9092/93 │  │:9092/93 │  │:9092/93 │             │    │
│  │  └─────────┘  └─────────┘  └─────────┘             │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────┐  ┌─────────────────┐                   │
│  │ Topic Operator  │  │ User Operator   │                   │
│  └─────────────────┘  └─────────────────┘                   │
└─────────────────────────────────────────────────────────────┘
```

## Connecting to Kafka

### Internal (within cluster)

```bash
# Bootstrap servers
kafka-cluster-kafka-bootstrap.strimzi.svc.cluster.local:9092  # Plain
kafka-cluster-kafka-bootstrap.strimzi.svc.cluster.local:9093  # TLS
```

### Testing with kafka-console-producer/consumer

```bash
# Deploy a test pod
kubectl run kafka-producer -ti --image=quay.io/strimzi/kafka:0.50.0-kafka-4.1.1 \
  --rm=true --restart=Never -n strimzi -- bin/kafka-console-producer.sh \
  --bootstrap-server kafka-cluster-kafka-bootstrap:9092 \
  --topic demo-topic

# In another terminal
kubectl run kafka-consumer -ti --image=quay.io/strimzi/kafka:0.50.0-kafka-4.1.1 \
  --rm=true --restart=Never -n strimzi -- bin/kafka-console-consumer.sh \
  --bootstrap-server kafka-cluster-kafka-bootstrap:9092 \
  --topic demo-topic --from-beginning
```

## Creating Topics

Topics can be created using the `KafkaTopic` CRD:

```yaml
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaTopic
metadata:
  name: my-topic
  namespace: strimzi
  labels:
    strimzi.io/cluster: kafka-cluster
spec:
  partitions: 3
  replicas: 3
  config:
    retention.ms: 604800000
```

## Creating Users

Users with ACLs can be created using the `KafkaUser` CRD:

```yaml
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaUser
metadata:
  name: my-user
  namespace: strimzi
  labels:
    strimzi.io/cluster: kafka-cluster
spec:
  authentication:
    type: tls
  authorization:
    type: simple
    acls:
      - resource:
          type: topic
          name: my-topic
          patternType: literal
        operations:
          - Read
          - Write
          - Describe
```

## Monitoring

Strimzi exposes Prometheus metrics. To enable monitoring, you can:

1. Enable the `dashboards.enabled: true` in `values.yaml`
2. Add PodMonitor/ServiceMonitor resources for VictoriaMetrics/Prometheus

## Resources

- [Strimzi Documentation](https://strimzi.io/documentation/)
- [Strimzi GitHub](https://github.com/strimzi/strimzi-kafka-operator)
- [Kafka Documentation](https://kafka.apache.org/documentation/)
