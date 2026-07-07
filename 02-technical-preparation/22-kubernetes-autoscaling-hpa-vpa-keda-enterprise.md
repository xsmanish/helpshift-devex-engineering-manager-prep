
# Kubernetes Autoscaling in Enterprise Platforms
## HPA, VPA, KEDA and Enterprise EKS Design

---

# Table of Contents

1. Introduction
2. Why Autoscaling Matters
3. Kubernetes Autoscaling Landscape
4. Horizontal Pod Autoscaler (HPA)
5. Vertical Pod Autoscaler (VPA)
6. Cluster Autoscaler vs Karpenter
7. What is KEDA?
8. Why We Chose KEDA
9. Enterprise Autoscaling Architecture
10. Cluster Add-on Model
11. KEDA Internal Architecture
12. Autoscaling Flow
13. Enterprise Deployment Architecture
14. AWS CDK Add-on Pattern
15. KEDA Installation
16. Scaling Scenarios
17. Production Best Practices
18. Common Pitfalls
19. Interview Questions
20. Executive Summary

---

# Introduction

Modern cloud-native applications experience dynamic workloads.

Examples:

- Black Friday
- Flash Sales
- Marketing Campaigns
- Batch Processing
- Event Processing
- Kafka Consumer Surges
- API Traffic Spikes

Provisioning infrastructure for peak load results in:

- Increased costs
- Underutilized resources

Provisioning for average load results in:

- Performance degradation
- Service instability

Autoscaling solves this problem.

---

# Why Autoscaling Matters

Without Autoscaling

```mermaid
graph LR

LOW["Low Traffic"]

FIXED["10 Pods"]

HIGH["High Traffic"]

LOW --> FIXED
HIGH --> FIXED
```

Problems:

- Wasted compute during low traffic
- Resource starvation during spikes

---

With Autoscaling

```mermaid
graph LR

LOW["Low Traffic"]

TWO["2 Pods"]

HIGH["High Traffic"]

TWENTY["20 Pods"]

LOW --> TWO
HIGH --> TWENTY
```

Benefits:

- Cost Optimization
- Better Availability
- Improved Performance
- Efficient Resource Utilization

---

# Kubernetes Autoscaling Landscape

There are three independent scaling layers.

```mermaid
flowchart TB

TRAFFIC["Application Traffic"]

HPA["HPA / KEDA"]

PODS["Pods"]

VPA["VPA"]

RESOURCES["CPU & Memory"]

KARPENTER["Karpenter"]

NODES["EC2 Nodes"]

TRAFFIC --> HPA

HPA --> PODS

PODS --> VPA

VPA --> RESOURCES

PODS --> KARPENTER

KARPENTER --> NODES
```

---

# Horizontal Pod Autoscaler (HPA)

## What HPA Does

HPA scales:

```text
Number of Pods
```

Example:

```text
2 Pods
↓
10 Pods
↓
20 Pods
```

---

# HPA Metrics

Traditional HPA can scale using:

- CPU
- Memory
- Custom Metrics

Example:

```yaml
targetCPUUtilizationPercentage: 70
```

Meaning:

```text
If CPU > 70%
Increase Pods
```

---

# HPA Example

```mermaid
graph LR

CPU["CPU 30%"]

P2["2 Pods"]

CPU --> P2
```

---

Traffic Spike

```mermaid
graph LR

CPU["CPU 90%"]

P10["10 Pods"]

CPU --> P10
```

---

# HPA Limitations

Traditional HPA works well for:

- APIs
- Web Applications

Not ideal for:

- Kafka
- SQS
- RabbitMQ
- Event Processing

Why?

Because CPU is not always correlated to workload.

---

# Vertical Pod Autoscaler (VPA)

## What VPA Does

VPA changes:

```text
CPU Requests
Memory Requests
```

Instead of Pod Count.

---

Example

Before

```yaml
resources:
  requests:
    cpu: 500m
    memory: 512Mi
```

After

```yaml
resources:
  requests:
    cpu: 2000m
    memory: 2Gi
```

---

# VPA Architecture

```mermaid
flowchart LR

WORKLOAD

RECOMMENDER

UPDATER

ADMISSION

WORKLOAD --> RECOMMENDER

RECOMMENDER --> UPDATER

UPDATER --> ADMISSION
```

---

# VPA Components

## Recommender

Analyzes resource consumption.

---

## Updater

Evicts Pods when updates required.

---

## Admission Controller

Injects recommendations into Pods.

---

# HPA vs VPA

| Feature | HPA | VPA |
|----------|----------|----------|
| Scale Pods | Yes | No |
| Scale CPU | No | Yes |
| Scale Memory | No | Yes |
| Restart Pods | No | Sometimes |
| Stateless Apps | Excellent | Good |
| Stateful Apps | Good | Excellent |

---

# Why HPA and VPA Together Can Be Dangerous

Example:

HPA says:

```text
Add Pods
```

VPA says:

```text
Increase CPU
```

Both can fight each other.

This is called:

```text
Scaling Oscillation
```

---

Enterprise recommendation:

```text
HPA/KEDA for APIs

VPA Recommendations Only

Do not auto-apply VPA
```

---

# Cluster Scaling Layer

Pods need nodes.

If HPA creates:

```text
100 Pods
```

But cluster only has:

```text
2 Nodes
```

Pods remain Pending.

---

# Karpenter Solves This

```mermaid
flowchart LR

KEDA

HPA

PODS

KARPENTER

EC2

KEDA --> HPA

HPA --> PODS

PODS --> KARPENTER

KARPENTER --> EC2
```

---

# What is KEDA?

KEDA stands for:

```text
Kubernetes Event Driven Autoscaling
```

Open Source CNCF Project.

Purpose:

Scale workloads using events instead of CPU.

---

# Why KEDA Exists

Traditional HPA:

```text
CPU
Memory
```

KEDA:

```text
Kafka Lag
SQS Messages
RabbitMQ Queue
Prometheus Metrics
CloudWatch Metrics
Datadog Metrics
Dynatrace Metrics
Azure Service Bus
Redis Queue
```

---

# Why We Chose KEDA

Our platform contains:

- Microservices
- Event Consumers
- Kafka Connectors
- Background Workers
- Batch Jobs

CPU is not always meaningful.

Example:

Kafka Consumer

```text
CPU = 10%
Lag = 500000 Messages
```

Traditional HPA sees:

```text
No scaling required
```

KEDA sees:

```text
Huge backlog
Scale immediately
```

---

# Enterprise Autoscaling Architecture

```mermaid
flowchart TB

KAFKA["Kafka"]

SQS["SQS"]

PROM["Prometheus"]

CW["CloudWatch"]

KEDA["KEDA"]

HPA["Generated HPA"]

DEPLOY["Deployment"]

PODS["Pods"]

KARPENTER["Karpenter"]

NODES["Nodes"]

KAFKA --> KEDA
SQS --> KEDA
PROM --> KEDA
CW --> KEDA

KEDA --> HPA

HPA --> DEPLOY

DEPLOY --> PODS

PODS --> KARPENTER

KARPENTER --> NODES
```

---

# KEDA Internal Architecture

```mermaid
flowchart LR

SCALEDOBJECT

KEDAOP["KEDA Operator"]

METRICSERVER

HPA

DEPLOYMENT

SCALEDOBJECT --> KEDAOP

KEDAOP --> METRICSERVER

METRICSERVER --> HPA

HPA --> DEPLOYMENT
```

---

# Important Concept

KEDA does NOT replace HPA.

KEDA creates and manages HPA.

Flow:

```text
ScaledObject
↓
KEDA
↓
HPA
↓
Pods
```

---

# Cluster Add-on Model

In our platform:

KEDA is deployed as:

```text
Cluster Add-on
```

Managed by Platform Team.

Not by Application Teams.

---

# Enterprise Cluster Add-on Architecture

```mermaid
flowchart TB

PLATFORM["Platform Team"]

ADDON["KEDA Add-on"]

CLUSTER["EKS Cluster"]

TEAM1["Team A"]

TEAM2["Team B"]

TEAM3["Team C"]

PLATFORM --> ADDON

ADDON --> CLUSTER

TEAM1 --> CLUSTER
TEAM2 --> CLUSTER
TEAM3 --> CLUSTER
```

---

Benefits:

- Standardized Versioning
- Central Governance
- Security Reviews
- Easier Upgrades

---

# AWS CDK Cluster Add-on Pattern

Example Enterprise Construct

```typescript
export interface KedaAddonProps {
  cluster: eks.Cluster;
}

export class KedaAddon extends Construct {

  constructor(
    scope: Construct,
    id: string,
    props: KedaAddonProps
  ) {

    super(scope, id);

    props.cluster.addHelmChart("keda", {
      repository: "https://kedacore.github.io/charts",
      chart: "keda",
      namespace: "keda",
      release: "keda",
      version: "2.16.1"
    });
  }
}
```

---

# Enterprise Cluster Construct

```typescript
new EnterpriseEksCluster(this, "cluster", {

  addons: [
    "coredns",
    "vpc-cni",
    "kube-proxy",
    "metrics-server",
    "keda",
    "karpenter",
    "aws-load-balancer-controller",
    "external-dns",
    "cert-manager"
  ]
});
```

---

# KEDA Installation Flow

```mermaid
sequenceDiagram

participant CDK

participant EKS

participant Helm

participant KEDA

CDK->>EKS: Deploy Add-on

EKS->>Helm: Install Chart

Helm->>KEDA: Create Operator

KEDA->>KEDA: Start Controllers
```

---

# Example Scaling Scenario

Kafka Consumer

---

Traffic

```text
1 Million Messages
```

---

KEDA Trigger

```yaml
triggers:
- type: kafka
```

---

Scaled Object

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject

metadata:
  name: order-consumer

spec:

  scaleTargetRef:
    name: order-consumer

  minReplicaCount: 1

  maxReplicaCount: 50

  triggers:

  - type: kafka

    metadata:
      bootstrapServers: kafka:9092
      topic: orders
      consumerGroup: order-group

      lagThreshold: "1000"
```

---

# Scaling Flow

```mermaid
sequenceDiagram

participant Kafka

participant KEDA

participant HPA

participant Deployment

Kafka->>KEDA: Lag 50000

KEDA->>HPA: Metric Update

HPA->>Deployment: Scale to 25 Pods

Deployment->>Pods: Launch Pods
```

---

# Scale to Zero

One major KEDA advantage.

Traditional HPA:

```text
Minimum 1 Pod
```

KEDA:

```text
0 Pods
```

Possible.

---

Example

```yaml
minReplicaCount: 0
```

Useful for:

- Batch Jobs
- Workers
- Event Consumers

---

# Enterprise Production Best Practices

## KEDA

Use:

```yaml
pollingInterval: 30
cooldownPeriod: 300
```

Avoid aggressive scaling.

---

## HPA

Always define:

```yaml
minReplicas
maxReplicas
```

Never unlimited.

---

## VPA

Use:

```yaml
updateMode: Off
```

Recommendation only.

---

## Karpenter

Combine with:

```yaml
NodePools
Disruption Budgets
Consolidation
```

---

# Recommended Enterprise Architecture

```mermaid
flowchart TB

USERS

INGRESS

SERVICES

KEDA

HPA

PODS

KARPENTER

EC2

USERS --> INGRESS

INGRESS --> SERVICES

SERVICES --> KEDA

KEDA --> HPA

HPA --> PODS

PODS --> KARPENTER

KARPENTER --> EC2
```

---

# Common Pitfalls

## Missing Metrics Server

KEDA requires:

```text
metrics-server
```

---

## Unlimited Scaling

Bad:

```yaml
maxReplicaCount: 1000
```

---

## Aggressive Polling

Bad:

```yaml
pollingInterval: 1
```

Can overload metric sources.

---

## Ignoring Node Capacity

HPA without Karpenter causes:

```text
Pending Pods
```

---

# Interview Questions

## Why use KEDA instead of HPA?

KEDA supports event-driven metrics such as Kafka lag, SQS depth, Prometheus metrics, and CloudWatch metrics, whereas traditional HPA primarily relies on CPU and memory.

---

## Does KEDA replace HPA?

No.

KEDA dynamically creates and manages HPA resources.

---

## Why deploy KEDA as a Cluster Add-on?

To centralize governance, security, version management, and operational ownership within the Platform Engineering team.

---

## How does KEDA work with Karpenter?

KEDA scales Pods.

Karpenter scales Nodes.

Together they provide complete workload elasticity.

---

## Why avoid automatic VPA updates?

Automatic VPA updates can restart workloads and may conflict with HPA, creating unstable scaling behavior.

---

# Executive Summary

```text
KEDA
  ↓
Creates HPA
  ↓
Scales Pods
  ↓
Karpenter Adds Nodes
  ↓
Applications Handle Traffic
```

Enterprise Recommendation:

- KEDA for workload scaling
- HPA managed by KEDA
- VPA in recommendation mode only
- Karpenter for node scaling
- Managed as Platform Cluster Add-ons through AWS CDK Constructs

This architecture provides cost-efficient, highly elastic, event-driven autoscaling suitable for large-scale EKS platforms operating across multiple markets, environments, and thousands of microservices.