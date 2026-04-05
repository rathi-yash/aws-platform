# AWS Platform Engineering

A production-grade internal developer platform built 
incrementally on AWS — documenting the journey from 
a simple EKS deployment to a full GitOps-driven platform.

---

## Phase 1 🚧 — EKS Foundation (in progress)
Deploying a containerized app on EKS with Terraform,
Kubernetes manifests, and AWS Load Balancer Controller.

**What we're building:**
- EKS cluster with managed node groups
- VPC with public and private subnets
- AWS Load Balancer Controller for Ingress
- Kubernetes Deployment, Service, and Ingress
- GitHub Actions deploying to EKS

## Phase 2 📋 — Observability (planned)
Prometheus + Grafana for metrics and dashboards.

## Phase 3 📋 — GitOps with ArgoCD (planned)
Replace GitHub Actions with ArgoCD for declarative deployments.

## Phase 4 📋 — Reusable Terraform Modules (planned)
Extract infrastructure into reusable modules any team can consume.