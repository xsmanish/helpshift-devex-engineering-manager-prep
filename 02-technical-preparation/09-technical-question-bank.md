# Technical Question Bank

## Engineering Manager – Developer Productivity

---

# Purpose

This document contains the most likely technical and platform engineering questions asked during Engineering Manager, Platform Engineering, Developer Productivity, Cloud Infrastructure, and Internal Developer Platform interviews.

Unlike traditional interview question lists, this guide focuses on:

* What interviewers are evaluating
* Strong answer structures
* Executive-level responses
* Platform Engineering thinking
* Real-world examples

---

# How to Answer Technical Questions

Most candidates answer like engineers.

Engineering Managers should answer like:

```text
Business Problem
        ↓
Engineering Challenge
        ↓
Technical Solution
        ↓
Business Outcome
```

---

## Example

Weak Answer:

> We migrated workloads to Graviton.

Strong Answer:

> Infrastructure costs were growing significantly across our EKS platform. We evaluated AWS Graviton to improve price-performance efficiency. We validated application compatibility, updated CI/CD pipelines for multi-architecture builds, created platform standards, and gradually migrated workloads. The result was lower infrastructure costs while maintaining application reliability.

---

# Section 1

# Platform Engineering

---

## Q1. What is Platform Engineering?

### What Interviewers Are Evaluating

* Understanding of modern engineering organizations
* Internal Developer Platforms
* Developer Productivity

---

### Weak Answer

> Platform Engineering manages infrastructure.

---

### Strong Answer

> Platform Engineering focuses on building reusable capabilities, self-service workflows, and golden paths that enable developers to deliver software quickly and safely. The goal is to reduce cognitive load and improve developer productivity while maintaining governance and operational excellence.

---

### Real Example

Our NextGen Platform provides:

* EKS Clusters
* CI/CD Pipelines
* GitOps
* Observability
* CDK Constructs

as reusable platform capabilities.

---

## Q2. How is Platform Engineering Different from DevOps?

### Strong Answer

DevOps is a culture focused on collaboration between development and operations.

Platform Engineering is the implementation of that vision through reusable platforms, tooling, and self-service capabilities.

```text
DevOps = Philosophy

Platform Engineering = Productized Implementation
```

---

## Q3. What is an Internal Developer Platform?

### Strong Answer

An Internal Developer Platform (IDP) is a self-service platform that abstracts infrastructure complexity and provides standardized workflows for application teams.

Examples:

* Deployment Automation
* Environment Provisioning
* Observability
* Security Controls
* CI/CD Pipelines

---

### Interview Insight

Mention:

* Self-Service
* Golden Paths
* Reduced Cognitive Load
* Developer Experience

---

# Section 2

# Developer Productivity

---

## Q4. How Do You Measure Developer Productivity?

### Weak Answer

> Number of commits.

---

### Strong Answer

Developer productivity should be measured using outcome-oriented metrics.

Examples:

### DORA

* Deployment Frequency
* Lead Time
* MTTR
* Change Failure Rate

### SPACE

* Satisfaction
* Performance
* Activity
* Communication
* Efficiency

---

### Key Insight

Productivity ≠ Lines of Code

Productivity = Business Value Delivered

---

## Q5. What Are the Biggest Productivity Killers?

### Strong Answer

Common productivity bottlenecks include:

* Manual infrastructure provisioning
* Slow CI/CD pipelines
* Environment inconsistency
* Poor observability
* Excessive approvals
* Knowledge silos

---

### Real Example

NextGen CLI reduced manual onboarding activities and standardized platform workflows.

---

## Q6. How Would You Improve Developer Experience?

### Strong Answer

I would focus on:

1. Self-service capabilities
2. Platform standardization
3. Faster feedback loops
4. Better documentation
5. Improved observability
6. Reduced cognitive load

---

# Section 3

# Cloud Platform Engineering

---

## Q7. What Does a Cloud Platform Team Own?

### Strong Answer

A Cloud Platform team owns the foundational capabilities required by engineering teams.

Examples:

* AWS Accounts
* Networking
* Kubernetes
* CI/CD
* Security Controls
* Observability
* Governance

The platform should enable application teams without becoming a bottleneck.

---

## Q8. Why Use Multiple AWS Accounts?

### Strong Answer

Multi-account strategies improve:

* Security Isolation
* Governance
* Blast Radius Reduction
* Cost Allocation
* Compliance

---

### Real Example

Typical Structure:

```text
Security
Networking
Shared Services
Development
PreProd
Production
```

---

## Q9. What is Infrastructure as Code?

### Strong Answer

Infrastructure as Code enables infrastructure to be managed through version-controlled code rather than manual configuration.

Benefits:

* Repeatability
* Automation
* Governance
* Auditability
* Reduced Configuration Drift

---

## Q10. AWS CDK vs Terraform?

### Strong Answer

AWS CDK:

Pros:

* Developer Friendly
* Strong TypeScript Support
* AWS Native

Terraform:

Pros:

* Multi-Cloud
* Large Ecosystem
* Broad Adoption

For AWS-first organizations I generally prefer CDK because it improves developer productivity and enables reusable platform constructs.

---

# Section 4

# Kubernetes & EKS

---

## Q11. Why Kubernetes?

### Strong Answer

Kubernetes provides a standardized platform for deploying, scaling, and operating applications consistently across environments.

Benefits:

* Portability
* Scalability
* Reliability
* Automation

---

## Q12. Why EKS Instead of Self-Managed Kubernetes?

### Strong Answer

EKS reduces operational burden by providing a managed control plane while still offering Kubernetes flexibility.

Benefits:

* Reduced Operations
* Better Security
* AWS Integration
* Faster Platform Delivery

---

## Q13. What Problems Does Karpenter Solve?

### Strong Answer

Karpenter improves Kubernetes capacity management by dynamically provisioning nodes based on workload demand.

Benefits:

* Faster Scaling
* Better Utilization
* Reduced Costs

---

### Real Example

Used Karpenter NodePools for:

* AMD64 Workloads
* ARM64 Workloads
* Bottlerocket Nodes

---

## Q14. Why Bottlerocket?

### Strong Answer

Bottlerocket is an AWS-optimized container OS focused on security, immutability, and operational simplicity.

Benefits:

* Smaller Attack Surface
* Automated Updates
* Better Security Posture

---

# Section 5

# GitOps & Delivery

---

## Q15. What is GitOps?

### Strong Answer

GitOps uses Git as the source of truth for infrastructure and application deployment.

Changes are made through pull requests and automatically synchronized to runtime environments.

---

### Benefits

* Auditability
* Consistency
* Recovery
* Governance

---

## Q16. Why Argo CD?

### Strong Answer

Argo CD continuously reconciles desired state from Git to Kubernetes clusters.

Benefits:

* Drift Detection
* Automated Deployment
* Rollback Capability
* Multi-Cluster Support

---

## Q17. What Deployment Strategies Have You Used?

### Strong Answer

Examples:

* Rolling Updates
* Blue-Green
* Canary
* Progressive Delivery

Selection depends on application criticality and risk tolerance.

---

# Section 6

# Reliability & Observability

---

## Q18. What is Reliability?

### Strong Answer

Reliability is the ability of a system to consistently perform its intended function under expected operating conditions.

---

## Q19. Explain SLI, SLO and SLA

### Strong Answer

SLI

Measured indicator.

Example:

```text
99.95% Request Success Rate
```

---

SLO

Target objective.

Example:

```text
99.9% Availability
```

---

SLA

Customer commitment.

Example:

```text
99.5% Availability Contract
```

---

## Q20. What is an Error Budget?

### Strong Answer

An Error Budget represents the amount of unreliability a service can tolerate before reliability work must take priority over feature development.

---

## Q21. What is Observability?

### Strong Answer

Observability is the ability to understand system behavior through telemetry.

Core Signals:

* Metrics
* Logs
* Traces
* Events

---

### Real Example

Platform Stack:

* Prometheus
* Grafana
* Loki
* Dynatrace

---

# Section 7

# Architecture & System Design

---

## Q22. Design an Internal Developer Platform

### Expected Areas

* Self-Service
* CI/CD
* GitOps
* Security
* Observability
* Governance

---

### Strong Structure

```text
Developer Portal

↓
Templates

↓
CI/CD

↓
GitOps

↓
Kubernetes

↓
Observability
```

---

## Q23. Design a Multi-Cluster Platform

### Discussion Areas

* EKS
* ArgoCD
* Karpenter
* Observability
* Security
* Disaster Recovery

---

## Q24. Design a Governance Framework

### Strong Answer

Governance should be automated through:

* Policy as Code
* Security Scanning
* Infrastructure Validation
* Compliance Checks

---

### Tools

* OPA
* Checkov
* cdk-nag
* Kyverno

---

# Section 8

# Leadership + Technical Depth

---

## Q25. How Do You Balance Standardization and Flexibility?

### Strong Answer

I provide opinionated defaults and golden paths for the majority of use cases while allowing controlled exceptions through governance mechanisms.

---

## Q26. How Do You Drive Platform Adoption?

### Strong Answer

Platform adoption is driven through:

* Solving real developer problems
* Excellent documentation
* Self-service workflows
* Fast feedback loops
* Strong support model

---

## Q27. How Do You Prioritize Platform Investments?

### Strong Answer

I prioritize initiatives based on:

* Developer Impact
* Reliability Impact
* Security Risk Reduction
* Cost Optimization
* Strategic Alignment

---

## Q28. How Do You Handle Technical Debt?

### Strong Answer

Technical debt should be treated as an investment decision.

I evaluate:

* Risk
* Cost
* Business Impact
* Engineering Velocity

before prioritizing remediation work.

---

# Questions You Should Ask the Interviewer

## Platform

* How mature is the internal platform?
* What are the biggest productivity challenges today?
* How is platform success measured?

---

## Engineering

* How many engineering teams use the platform?
* What are the expectations from this role in the first six months?

---

## Organization

* How do you balance platform governance and developer autonomy?
* What does success look like after one year?

---

# Rapid Revision Sheet

## Platform Engineering

* Platform as Product
* Self-Service
* Golden Paths
* Cognitive Load Reduction

---

## Developer Productivity

* DORA
* SPACE
* Developer Experience

---

## Cloud Platform

* AWS
* IaC
* Multi-Account
* Governance

---

## Kubernetes

* EKS
* GitOps
* Karpenter
* Bottlerocket

---

## Reliability

* SLI
* SLO
* SLA
* Error Budget

---

# Final Interview Formula

Whenever answering a technical question:

```text
Business Problem

↓

Engineering Challenge

↓

Solution

↓

Outcome

↓

Lessons Learned
```

This structure consistently differentiates Engineering Managers from Senior Engineers and demonstrates platform leadership rather than individual contributor thinking.
