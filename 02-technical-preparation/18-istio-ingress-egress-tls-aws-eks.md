# Istio Ingress, Egress & TLS on AWS EKS
## Complete Interview Preparation Guide for Platform Engineers, SREs, Staff Engineers & Engineering Managers

---

# Table of Contents

1. What Problem Does Istio Solve?
2. Traditional Kubernetes Networking
3. Service Mesh Architecture
4. Istio Core Components
5. AWS EKS + Istio Architecture
6. Ingress Traffic Management
7. Gateway Resource
8. Virtual Services
9. Destination Rules
10. TLS & mTLS
11. Egress Traffic Management
12. ServiceEntry
13. Complete Enterprise Architecture
14. Traffic Flow Walkthrough
15. Observability with Dynatrace
16. Canary Deployments
17. Circuit Breakers & Retries
18. Production Best Practices
19. Troubleshooting
20. Interview Questions & Answers
21. Executive Summary

---

# What Problem Does Istio Solve?

Kubernetes provides:

- Service Discovery
- Load Balancing
- Scheduling
- Auto Scaling
- Self Healing

However, Kubernetes does not provide:

- Traffic Splitting
- Canary Releases
- mTLS
- Service-to-Service Encryption
- Distributed Tracing
- Circuit Breaking
- Retry Policies
- Service Dependency Mapping
- Advanced Traffic Routing

These capabilities are provided by a Service Mesh.

---

# Traditional Kubernetes Networking

Without Istio:

```mermaid
flowchart LR

USER[User]

INGRESS[Ingress Controller]

PRODUCT[Product Service]

ORDER[Order Service]

PAYMENT[Payment Service]

USER --> INGRESS

INGRESS --> PRODUCT
INGRESS --> ORDER
INGRESS --> PAYMENT
```

Problems:

- Limited visibility
- No traffic policies
- No service mesh
- No built-in security
- No canary deployments

---

# Service Mesh Architecture

With Istio:

```mermaid
flowchart LR

USER[User]

IGW[Istio Ingress Gateway]

EP1[Envoy]

PRODUCT[Product Service]

EP2[Envoy]

ORDER[Order Service]

EP3[Envoy]

PAYMENT[Payment Service]

USER --> IGW

IGW --> EP1
IGW --> EP2
IGW --> EP3

EP1 --> PRODUCT
EP2 --> ORDER
EP3 --> PAYMENT
```

Every request passes through Envoy proxies.

Benefits:

- Security
- Routing
- Observability
- Traffic Management
- Resilience

---

# Istio Core Components

## Control Plane

Responsible for:

- Service Discovery
- Configuration
- Certificate Distribution
- Policy Management

Component:

```text
Istiod
```

---

## Data Plane

Responsible for:

- Request Routing
- TLS
- Telemetry
- Traffic Policies

Component:

```text
Envoy Proxy
```

---

# Istio Architecture

```mermaid
flowchart TB

ISTIOD[Istiod]

subgraph Product Namespace

APP1[Product Service]

ENVOY1[Envoy Sidecar]

end

subgraph Order Namespace

APP2[Order Service]

ENVOY2[Envoy Sidecar]

end

ISTIOD --> ENVOY1
ISTIOD --> ENVOY2

ENVOY1 <--> ENVOY2

APP1 --> ENVOY1
APP2 --> ENVOY2
```

---

# AWS EKS + Istio Architecture

Typical Production Deployment:

```mermaid
flowchart TB

USER[Users]

ROUTE53[Route53]

WAF[AWS WAF]

ALB[AWS ALB]

INGRESS[Istio Ingress Gateway]

PRODUCT[Product Service]

ORDER[Order Service]

PAYMENT[Payment Service]

USER --> ROUTE53

ROUTE53 --> WAF

WAF --> ALB

ALB --> INGRESS

INGRESS --> PRODUCT
INGRESS --> ORDER
INGRESS --> PAYMENT
```

---

# Ingress Traffic Management

Ingress controls:

```text
External Traffic
       ↓
Kubernetes Cluster
```

Responsibilities:

- TLS Termination
- URL Routing
- Header Routing
- Traffic Splitting
- Security Policies

---

# Gateway Resource

Gateway defines how traffic enters the mesh.

Example:

```yaml
apiVersion: networking.istio.io/v1beta1

kind: Gateway

metadata:
  name: public-gateway

spec:
  selector:
    istio: ingressgateway

  servers:
  - port:
      number: 443
      name: https
      protocol: HTTPS

    tls:
      mode: SIMPLE
      credentialName: company-cert

    hosts:
    - api.company.com
```

---

# Ingress Request Flow

```mermaid
sequenceDiagram

participant User
participant ALB
participant Gateway
participant Service

User->>ALB: HTTPS Request

ALB->>Gateway: Forward Request

Gateway->>Service: Route Traffic

Service-->>Gateway: Response

Gateway-->>ALB: Response

ALB-->>User: HTTPS Response
```

---

# Virtual Services

Virtual Service defines routing logic.

Example:

```yaml
apiVersion: networking.istio.io/v1beta1

kind: VirtualService

metadata:
  name: product-routing

spec:

  hosts:
  - api.company.com

  gateways:
  - public-gateway

  http:

  - match:
    - uri:
        prefix: /products

    route:

    - destination:
        host: product-service
```

---

# Request Routing Example

```mermaid
flowchart LR

REQUEST[Incoming Request]

VS[Virtual Service]

PRODUCT[Product Service]

ORDER[Order Service]

PAYMENT[Payment Service]

REQUEST --> VS

VS -->|/products| PRODUCT

VS -->|/orders| ORDER

VS -->|/payments| PAYMENT
```

---

# Destination Rules

Destination Rules define how traffic behaves after routing.

Examples:

- Load Balancing
- Circuit Breaking
- Connection Pools
- Service Versions

```yaml
apiVersion: networking.istio.io/v1beta1

kind: DestinationRule

metadata:
  name: product

spec:

  host: product-service

  subsets:

  - name: v1
    labels:
      version: v1

  - name: v2
    labels:
      version: v2
```

---

# TLS & mTLS

One of the most important interview topics.

---

## TLS

Protects traffic between client and gateway.

```mermaid
flowchart LR

USER

TLS

GATEWAY

USER -->|HTTPS| GATEWAY
```

Benefits:

- Encryption
- Authentication
- Integrity

---

## mTLS

Protects traffic between services.

```mermaid
flowchart LR

SERVICEA[Service A]

SERVICEB[Service B]

SERVICEA -->|mTLS| SERVICEB
```

Benefits:

- Service Authentication
- Encryption
- Zero Trust Security

---

# TLS Termination Models

## Model 1 - TLS at ALB

```mermaid
flowchart LR

USER

ALB

ISTIO

SERVICE

USER -->|HTTPS| ALB

ALB -->|HTTP| ISTIO

ISTIO --> SERVICE
```

Simple but not ideal.

---

## Model 2 - TLS Passthrough

```mermaid
flowchart LR

USER

ALB

GATEWAY

SERVICE

USER -->|HTTPS| ALB

ALB -->|HTTPS| GATEWAY

GATEWAY --> SERVICE
```

Recommended.

---

## Model 3 - End-to-End Encryption

```mermaid
flowchart LR

USER

GATEWAY

SERVICE

USER -->|HTTPS| GATEWAY

GATEWAY -->|mTLS| SERVICE
```

Enterprise Best Practice.

---

# Egress Traffic Management

Egress controls:

```text
Cluster
    ↓
External Systems
```

Examples:

- Salesforce
- SAP
- Stripe
- ServiceNow
- AWS APIs
- External Vendors

---

# Without Egress Gateway

```mermaid
flowchart LR

APP[Application]

EXT[External API]

APP --> EXT
```

Problems:

- No Governance
- No Auditing
- No Visibility
- Security Risks

---

# With Egress Gateway

```mermaid
flowchart LR

APP[Application]

SIDECAR[Envoy Sidecar]

EGRESS[Istio Egress Gateway]

EXT[External API]

APP --> SIDECAR

SIDECAR --> EGRESS

EGRESS --> EXT
```

Benefits:

- Centralized Security
- Observability
- Governance
- Compliance

---

# ServiceEntry

Allows Istio to recognize external services.

Example:

```yaml
apiVersion: networking.istio.io/v1beta1

kind: ServiceEntry

metadata:
  name: salesforce

spec:

  hosts:
  - login.salesforce.com

  ports:
  - number: 443
    name: https
    protocol: HTTPS

  location: MESH_EXTERNAL

  resolution: DNS
```

---

# Egress Request Flow

```mermaid
sequenceDiagram

participant App

participant Sidecar

participant EgressGateway

participant Salesforce

App->>Sidecar: Outbound Request

Sidecar->>EgressGateway: Route Request

EgressGateway->>Salesforce: HTTPS Call

Salesforce-->>EgressGateway: Response

EgressGateway-->>Sidecar: Response

Sidecar-->>App: Response
```

---

# Complete Enterprise Architecture

This is the architecture you should remember for interviews.

```mermaid
flowchart TB

USER[Users]

ROUTE53[Route53]

WAF[AWS WAF]

ALB[AWS ALB]

INGRESS[Istio Ingress Gateway]

VS[Virtual Service]

PRODUCT[Product Service]

ORDER[Order Service]

PAYMENT[Payment Service]

EGRESS[Istio Egress Gateway]

SALESFORCE[Salesforce]

SAP[SAP]

STRIPE[Stripe]

USER --> ROUTE53

ROUTE53 --> WAF

WAF --> ALB

ALB --> INGRESS

INGRESS --> VS

VS --> PRODUCT
VS --> ORDER
VS --> PAYMENT

PRODUCT --> EGRESS
ORDER --> EGRESS
PAYMENT --> EGRESS

EGRESS --> SALESFORCE
EGRESS --> SAP
EGRESS --> STRIPE
```

---

# Complete Traffic Flow

```mermaid
flowchart LR

User

Route53

ALB

IngressGateway

VirtualService

Microservice

EgressGateway

ExternalAPI

User --> Route53

Route53 --> ALB

ALB --> IngressGateway

IngressGateway --> VirtualService

VirtualService --> Microservice

Microservice --> EgressGateway

EgressGateway --> ExternalAPI
```

---

# Observability with Dynatrace

Dynatrace provides complete visibility.

```mermaid
flowchart TB

USER

INGRESS

SERVICE

EGRESS

EXTAPI

ENVOY

ONEAGENT

ACTIVEGATE

DYNATRACE

USER --> INGRESS

INGRESS --> SERVICE

SERVICE --> EGRESS

EGRESS --> EXTAPI

SERVICE --> ENVOY

INGRESS --> ENVOY

EGRESS --> ENVOY

ENVOY --> ONEAGENT

ONEAGENT --> ACTIVEGATE

ACTIVEGATE --> DYNATRACE
```

---

# What Dynatrace Shows

Infrastructure:

- Nodes
- Containers
- CPU
- Memory

Kubernetes:

- Namespaces
- Deployments
- Pods

Applications:

- Transactions
- Errors
- Response Times

Service Mesh:

- Ingress Traffic
- Egress Traffic
- Service Dependencies
- Distributed Traces

---

# Canary Deployments

Traffic can be split between versions.

```mermaid
flowchart LR

USERS

VS

V1

V2

USERS --> VS

VS -->|90%| V1

VS -->|10%| V2
```

Virtual Service:

```yaml
http:

- route:

  - destination:
      host: product-service
      subset: v1
    weight: 90

  - destination:
      host: product-service
      subset: v2
    weight: 10
```

---

# Circuit Breakers

Prevent cascading failures.

```yaml
trafficPolicy:

  connectionPool:
    tcp:
      maxConnections: 100

  outlierDetection:
    consecutive5xxErrors: 5
```

---

# Retry Policies

```yaml
retries:
  attempts: 3
  perTryTimeout: 2s
```

---

# Production Best Practices

## Security

- Enable STRICT mTLS
- Use Authorization Policies
- Restrict Egress Access

## Networking

- Use Dedicated Gateways
- Use ServiceEntry for External Services

## Observability

- Integrate Dynatrace
- Monitor Envoy Metrics
- Monitor Gateway Health

## Operations

- Use Canary Deployments
- Use Circuit Breakers
- Use Retry Policies

---

# Troubleshooting

Check Gateways

```bash
kubectl get gateway -A
```

Check Virtual Services

```bash
kubectl get virtualservice -A
```

Check Destination Rules

```bash
kubectl get destinationrule -A
```

Check Proxy Config

```bash
istioctl proxy-config routes <pod>
```

Analyze Configuration

```bash
istioctl analyze
```

---

# Interview Questions & Answers

## What is the difference between Ingress and Egress?

Ingress:

```text
Outside → Cluster
```

Examples:

- Browser Requests
- Mobile Apps
- APIs

Egress:

```text
Cluster → Outside
```

Examples:

- Salesforce
- SAP
- Stripe
- AWS APIs

---

## What is a Virtual Service?

Defines routing rules for incoming traffic.

Examples:

- URL Routing
- Header Routing
- Canary Releases

---

## What is a Destination Rule?

Defines traffic policies after routing.

Examples:

- Load Balancing
- Circuit Breaking
- Service Subsets

---

## What is ServiceEntry?

Registers external services with Istio.

Examples:

- Salesforce
- Stripe
- SAP

---

## Why use Egress Gateway?

Provides:

- Security
- Governance
- Auditing
- Compliance
- Observability

for outbound traffic.

---

## How does Dynatrace monitor Istio?

Dynatrace observes:

- Envoy Sidecars
- Ingress Gateways
- Egress Gateways
- Service Dependencies
- Distributed Traces
- External API Calls

---

# Executive Summary

```text
User
 ↓
Route53
 ↓
AWS WAF
 ↓
AWS ALB
 ↓
Istio Ingress Gateway
 ↓
Virtual Service
 ↓
Microservices
 ↓
Istio Egress Gateway
 ↓
External Systems

Salesforce
SAP
Stripe

Observability Everywhere
        ↓
Dynatrace
```

## Interview Answer (2-Minute Version)

"In our AWS EKS platform, external traffic enters through Route53, AWS WAF, and ALB before reaching the Istio Ingress Gateway. Gateway and Virtual Services handle routing decisions, while Destination Rules manage traffic policies such as load balancing and circuit breaking. Each workload runs with an Envoy sidecar providing service mesh capabilities like mTLS, retries, and observability. Outbound communication is controlled through Istio Egress Gateway and ServiceEntries, allowing secure and auditable access to systems such as Salesforce, SAP, and Stripe. Dynatrace provides end-to-end observability by monitoring ingress traffic, service-to-service communication, egress traffic, and external dependencies through OneAgent and ActiveGate."