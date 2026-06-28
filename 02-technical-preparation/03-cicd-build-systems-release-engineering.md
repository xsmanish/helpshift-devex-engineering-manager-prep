# CI/CD, Build Systems & Release Engineering

## Purpose

This chapter covers CI/CD pipelines, build systems, and release engineering — core to the Developer Productivity Manager role. Covers architecture patterns, tooling choices, trade-offs, and interview preparation at Staff+/Director depth.

---

## Key Concepts

| Concept | Definition | Why It Matters |
|---------|------------|----------------|
| **Continuous Integration (CI)** | Automatically building and testing every code change | Catches issues early; enables rapid feedback |
| **Continuous Delivery (CD)** | Automatically deploying changes to production after CI | Reduces deployment risk; enables frequent releases |
| **Continuous Deployment** | Every change that passes CI goes to production automatically | Highest velocity; requires strong safety guarantees |
| **GitOps** | Git as single source of truth for declarative deployments | Audit trail, rollback, self-service |
| **Build System** | Toolchain that compiles, tests, and produces artifacts | Performance and reliability depend on build system design |
| **Release Engineering** | Managing the software release lifecycle | Critical for compliance, rollbacks, customer communication |

---

## Detailed Content

### 1. CI/CD Pipeline Architecture

#### The Modern CI/CD Pipeline

```
CI Stage:
Code Commit -> Lint & Format -> Unit Tests -> Build & Package -> Security Scan -> Push Artifact

CD Stage (GitOps):
Push Image -> Update K8s Manifest -> PR -> Merge -> ArgoCD Sync -> Canary Deploy -> Health Check

Post-Deploy:
Smoke Tests -> Metrics Check -> Alert if Anomaly
```

#### Pipeline Stages

| Stage | Purpose | Tools | Success Criteria |
|-------|---------|-------|------------------|
| Lint & Format | Enforce code style | ESLint, Prettier | Zero warnings |
| Unit Tests | Verify components | Jest, JUnit, pytest | >80% coverage, all passing |
| Build & Package | Create container image | Docker, BuildKit | Image < 500MB, build < 10min |
| Security Scan | Identify vulnerabilities | Snyk, Trivy, AWS Inspector | Zero critical/high CVEs |
| Deploy | Apply changes via GitOps | ArgoCD, CodeDeploy | Health check passes |
| Post-Deploy | Verify deployment health | Prometheus, CloudWatch | P99 latency < threshold |

> **Interview Insight:** Don't just list tools. Explain **why** you chose each tool and **what trade-offs** you considered.

---

### 2. CI/CD Tooling Deep-Dive

#### Tool Comparison

| Tool | Strengths | Weaknesses | Best For | Your Experience |
|------|-----------|------------|----------|-----------------|
| **Jenkins** | Customisable, huge plugin ecosystem | Maintenance overhead, Groovy DSL | Complex pipelines, compliance-heavy environments | ✅ Extensive |
| **GitHub Actions** | Native GitHub, no infrastructure | Limited for complex workflows | Standard CI/CD | ✅ Extensive |
| **CodePipeline+CodeBuild** | Deep AWS integration | Limited customisation | AWS-native teams | ✅ Extensive |
| **GitLab CI** | Single application | Requires GitLab | GitLab-native teams | ⬜ Familiar |
| **CircleCI** | Fast, good caching | Cost at scale | Speed out of the box | ⬜ Familiar |

#### Decision Framework

- **< 10 engineers** → managed (GitHub Actions)
- **> 50 engineers** → custom (templates + self-service)
- **Compliance (SOC2/HIPAA)** → self-hosted or enterprise tier
- **Need custom deploy logic** → custom; standard workflows → managed

---

### 3. Build Systems & Optimisation

#### Build Optimisation Strategies

| Strategy | How It Works | Impact | When to Use |
|----------|-------------|--------|-------------|
| Parallel Execution | Run independent steps in parallel | 2-5x faster | Most pipelines |
| Dependency Caching | Cache node_modules, .m2, pip | 30-60% faster | Every pipeline |
| Docker Layer Caching | Cache unchanged layers | 40-70% faster | Containerised builds |
| Incremental Builds | Only rebuild changed modules | 5-10x faster | Monorepos, large codebases |
| Build Matrix | Run builds for multiple targets in parallel | Same time for N targets | Multi-arch support |
| Distributed Builds | Spread across multiple machines | 2-20x faster | Very large codebases |

#### Multi-Architecture Builds (Graviton Migration Relevance)

```yaml
# GitHub Actions multi-architecture build matrix
name: Build and Push
on: [push]

jobs:
  build:
    strategy:
      matrix:
        arch: [amd64, arm64]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          platforms: linux/${{ matrix.arch }}
          tags: ${{ env.ECR_REPO }}:${{ github.sha }}-${{ matrix.arch }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  manifest:
    needs: build
    steps:
      - name: Create multi-arch manifest
        run: |
          docker manifest create ${{ env.ECR_REPO }}:${{ github.sha }} \
            ${{ env.ECR_REPO }}:${{ github.sha }}-amd64 \
            ${{ env.ECR_REPO }}:${{ github.sha }}-arm64
          docker manifest push ${{ env.ECR_REPO }}:${{ github.sha }}
```

> **Interview Insight:** Frame Graviton migration as: "I implemented multi-architecture CI/CD pipelines enabling migration to Graviton instances with zero deployment risk."

---

### 4. Release Engineering

#### Branching Strategy

| Strategy | Pros | Cons | Best For |
|----------|------|------|----------|
| Trunk-Based | Simplest, continuous integration, fast feedback | Requires discipline, strong testing | Elite teams |
| GitHub Flow | Simple, well-understood | No release branches for hotfixes | Most teams |
| GitLab Flow | Environment-per-branch, good for compliance | More branches to manage | Teams needing environment parity |
| Git Flow | Very structured, handles hotfixes | Complex, not CI-friendly | Release-based delivery |

**Recommendation:** Start with GitHub Flow; adopt trunk-based development for speed.

#### Release Lifecycle

```
Feature Complete -> Release Branch -> Stabilisation -> RC Staging -> QA -> Canary -> 5% -> 25% -> 50% -> 100% -> Monitoring -> Hotfix if needed
```

#### Versioning

| Strategy | Format | Example | When to Use |
|----------|--------|---------|-------------|
| Semantic | MAJOR.MINOR.PATCH | 2.1.4 | Public APIs, libraries |
| Calendar | YYYY.MM.PATCH | 2024.03.1 | SaaS releases |
| Git SHA | <commit_sha> | a1b2c3d4 | Immutable deployments |
| Build Number | <incrementing> | 1423 | Simple internal releases |

#### Release Engineering Best Practices

1. **Immutable Artifacts:** Never rebuild from source per environment — promote same artifact
2. **Release Notes Automation:** Generate from commit messages / PR titles
3. **Feature Flags:** Decouple deployment from release — ship code dark, enable via flag
4. **Automated Rollback:** If health checks fail, auto-rollback
5. **Deployment Freeze Windows:** Define windows when deployments are not allowed
6. **Change Advisory Board:** For high-risk changes, require approval

---

### 5. GitOps with ArgoCD

#### GitOps Workflow

```
Developer -> Code Commit -> CI Builds Image -> Image pushed to ECR
Developer -> Updates K8s manifest in Git -> PR Created -> PR Merged
ArgoCD -> Detects drift -> Syncs to desired state -> Health check -> Auto-rollback if unhealthy
```

#### ArgoCD Key Concepts

| Concept | Description |
|---------|-------------|
| Application | Logical grouping of K8s resources managed together |
| Sync | Process of reconciling desired state (Git) with live state (K8s) |
| Sync Policy | Manual, automated, or automated with prune |
| Sync Waves | Order of resource application within a sync |
| Health Check | Assessment of whether application is running correctly |
| Rollback | Revert to a previous known-good state (just sync previous commit) |
| Multi-Cluster | Manage deployments across multiple clusters |

#### ArgoCD vs Flux

| Aspect | ArgoCD | Flux |
|--------|--------|------|
| UI | Rich web UI, CLI, API | CLI-only, Web UI via Weave |
| Multi-Cluster | Native, well-supported | Supported via Kustomize |
| Rollback | Native to any sync | Via Git revert |
| SSO | Yes (Dex, OIDC, Okta) | Via Weave GitOps |
| Learning Curve | Moderate | Steeper (CRD-heavy) |
| Best For | Teams wanting rich UI, complex sync policies | Kustomize users, Git-native |

> **Interview Insight:** "We chose ArgoCD over Flux because our team needed a web UI for visibility. Trade-off was managing the ArgoCD server itself."

---

### 6. CI/CD at Scale

#### Scaling Challenges

| Challenge | Symptom | Solution |
|-----------|---------|----------|
| Pipeline Sprawl | 100s of similar pipeline definitions | Pipeline templates / composite actions |
| Build Queue Wait | Developers waiting for builds | Increase parallel workers, optimise build time |
| Test Flakiness | Non-deterministic test failures | Quarantine flaky tests, require fixes |
| Secret Management | Hardcoded credentials | AWS Secrets Manager / Vault, IRSA for K8s |
| Multi-Tenancy | Teams stepping on each other's pipelines | Namespace isolation, resource quotas |
| Cost at Scale | CI/CD bills growing | Spot instances for builds, caching, tiered runners |

#### Self-Service Pipeline Platform

```
Developer -> scaffolds service -> Pipeline template auto-applied -> Customises via config file
Platform Team -> Maintains templates -> Updates propagate -> Monitors pipeline health
Templates: service-pipeline.yaml, library-pipeline.yaml, data-pipeline.yaml, infra-pipeline.yaml
```

---

### 7. DevSecOps Pipeline

#### Security Gates

```
Commit -> SAST (SonarQube) -> SCA (Snyk/Trivy) -> Container Scan -> Secret Detection -> License Compliance -> All Pass? YES/NO
YES -> Build & Deploy
NO -> Block Pipeline -> Notify Developer
```

| Security Check | Tool | What It Catches | Block on |
|----------------|------|-----------------|----------|
| SAST | SonarQube, Semgrep, CodeQL | SQL injection, XSS, insecure deserialisation | Critical/high |
| SCA | Snyk, Dependabot, Trivy | Known CVEs in dependencies | Critical/high |
| Container Scan | Trivy, AWS Inspector | OS-level CVEs, misconfigurations | Critical/high |
| Secret Detection | GitLeaks, Talisman | Hardcoded keys, tokens, passwords | Any detected |
| License Compliance | FOSSA, License Finder | GPL/AGPL in commercial products | Copyleft |
| IaC Scan | Checkov, tfsec, cdk-nag | Cloud misconfigurations | Critical/high |

---

## Architecture / Diagrams

### Multi-Stage CI/CD Reference Architecture (AWS)

```
GitHub -> GitHub Actions (CI)
  -> Build Matrix (amd64 + arm64)
  -> Unit & Integration Tests
  -> Security Scan (Trivy + Snyk)
  -> Push to ECR

ECR -> Update K8s Manifests in Git -> PR -> Merge

ArgoCD Detects Drift
  -> Sync to Dev -> Integration Tests
  -> Sync to Staging -> E2E Tests
  -> Sync to Production (Canary: 5% -> 25% -> 50% -> 100%)

Prometheus + Grafana Monitor
  -> DORA Metrics Healthy? YES -> Complete
  -> NO -> Auto-Rollback
```

---

## Interview Questions & Answers

### Q1: "How would you design a CI/CD pipeline for a microservices architecture at scale?"

**Strong Answer:**

> "Three-layer architecture:
>
> **Layer 1: Pipeline Templates (Platform owns)** — Reusable templates per service type. Teams customise via config file (`pipeline-config.yaml`).
>
> **Layer 2: Pipeline Execution (Per Service)** — Generated pipeline from template. Runs CI (build, test, scan) and triggers CD via GitOps.
>
> **Layer 3: GitOps Deployment (ArgoCD)** — CI pushes image and updates K8s manifest in Git. ArgoCD detects change and syncs. Canary: 5% -> 25% -> 50% -> 100% with health checks.
>
> Key decisions: trunk-based development, immutable tags (git SHA), automated rollback on failure, pipeline as code (templates in YAML, stored in Git)."

**Weak Answer:**

> "I'd set up GitHub Actions with a workflow that builds and deploys."

### Q2: "Walk me through a GitOps deployment with ArgoCD."

**Strong Answer:**

> "1. Developer commits code -> CI builds and pushes image to ECR
> 2. CI updates K8s manifest in Git with new image tag (git SHA)
> 3. Developer creates PR -> reviewed -> merged to main
> 4. ArgoCD detects drift between desired state (main branch) and live state (K8s cluster)
> 5. ArgoCD initiates sync — applies new manifest to cluster
> 6. ArgoCD monitors health — checks pods pass readiness probes
> 7. If unhealthy -> auto-rollback to previous sync
> 8. If healthy -> deployment complete
>
> Benefit: every change is in Git, every deploy is auditable, rollback is just reverting a Git commit."

### Q3: "How do you reduce CI/CD pipeline build times?"

**Strong Answer:**

> "1. **Measure first** — Identify slowest stages. Is it compilation, testing, or Docker build?
> 2. **Parallelise** — Run linting, unit tests, and security scans in parallel
> 3. **Cache aggressively** — Dependency caching, Docker layer caching (BuildKit), remote caching
> 4. **Optimise Docker builds** — Multi-stage builds, order layers from least to most frequently changing
> 5. **Use faster hardware** — GitHub Actions larger runners, more CPU/memory
> 6. **Incremental builds** — Only rebuild changed services (Nx, Turborepo)
> 7. **Tiered testing** — Unit on every commit, integration on PR merge, E2E before production
>
> Real result: reduced average build time from 45 minutes to 12 minutes."

### Q4: "How do you handle a failed deployment?"

**STAR Format:**

| Element | Description |
|---------|-------------|
| Situation | Canary deployment to 5% caused elevated error rates (5% vs baseline 0.1%) |
| Task | Detect issue, mitigate impact, fix root cause, improve system |
| Action | 1. ArgoCD health check triggered automated rollback. 2. PagerDuty alerted on-call. 3. Post-mortem identified database migration ran before code was ready. 4. Added DB migration checks to CI pipeline |
| Result | MTTR reduced from 45min to 5min (automated rollback). Zero customer impact. DB migration check became standard |

---

## Common Follow-Up Questions

| Question | Tests | Key Insight |
|----------|-------|-------------|
| "How do you handle database migrations in CI/CD?" | Release depth | Backward-compatible changes; deploy code before migration |
| "How do you manage secrets across pipelines?" | Security | AWS Secrets Manager / Vault; IRSA; never in Git |
| "How do you test CI/CD changes safely?" | Ops maturity | CI/CD sandbox; test on non-production first |
| "How do you handle hotfixes?" | Release mgmt | Hotfix branch from release tag; same quality checks |
| "How do you handle deployment blackout periods?" | Governance | Calendar-based blackout windows; deployment freeze automation |
| "What CI/CD health metrics do you track?" | Platform metrics | Pipeline success rate, build queue time, build time (p50/p95) |

---

## Real World Examples

### Example 1: Jenkins to GitHub Actions Migration

**Problem:** Jenkins monolith with 50+ shared pipelines. Single broken build blocked all deployments.

**Solution:** GitHub Actions composite action templates. Each service configured via `pipeline-config.yaml`. Migrated 5 services/week over 10 weeks.

**Result:** Build time 45min -> 12min. Pipeline maintenance 1 FT -> 0.2 FT. Deploy frequency 2x/week -> 15x/week.

### Example 2: Release Engineering for Compliance

**Problem:** Financial services required approval gates. Manual approval averaged 2 days.

**Solution:** Standard changes (85%) auto-approved. Normal changes (12%) single approver via Slack. Emergency changes (3%) immediate approval, time-boxed 24 hours.

**Result:** 85% no approval needed. 12% approved within 2 hours. 3% within 30 minutes.

---

## Common Mistakes

| Mistake | Why It's a Problem | How to Avoid |
|---------|-------------------|--------------|
| Rebuilding artifacts per environment | Different artifacts -> environment drift | Promote same immutable artifact through all environments |
| Secrets in pipeline config | Security breach | External secret management |
| Overly complex branching | Release delays, merge conflicts | Start with GitHub Flow |
| Hardcoded environment references | Can't deploy to new regions | Parameterise everything |
| No rollback strategy | Long outage | Automated rollback, practice it |
| Ignoring pipeline health | Broken pipeline stays broken | Pipeline health dashboard; CI/CD SLO |

---

## Revision Notes

| Topic | Key Points |
|-------|------------|
| CI Pipeline | Build -> Test -> Scan -> Package -> Push |
| CD Pipeline | GitOps PR -> Merge -> ArgoCD Sync -> Canary -> Health Check |
| GitOps | Git is source of truth; ArgoCD reconciles desired vs live |
| Build Optimisation | Caching, parallelisation, incremental builds |
| Release Engineering | Trunk-based dev > Git Flow; immutable artifacts; feature flags |
| Security | SAST + SCA + Container Scan + Secret Detection + IaC Scan |
| Your Experience | Jenkins, GitHub Actions, CodeBuild, ArgoCD, Graviton multi-arch, NextGen CLI |

---

## Key Takeaways

1. **Pipeline templates scale CI/CD.** Platform teams write templates; teams configure them.
2. **GitOps changes deployment.** Every change auditable, every deploy repeatable, rollback = Git revert.
3. **Build optimisation is a force multiplier.** 45min -> 12min saves 11 hours/day of engineer wait time.
4. **Security embedded in pipeline.** SAST, SCA, container scanning on every commit.
5. **Immutable artifacts eliminate drift.** Build once, promote same artifact through environments.
6. **Feature flags decouple deployment from release.** Deploy to production without making visible.
