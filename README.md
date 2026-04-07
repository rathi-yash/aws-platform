# AWS Platform Engineering

A production-grade internal developer platform built 
incrementally on AWS — documenting the journey from 
a simple EKS deployment to a full GitOps-driven platform.

---

## Phase 1 ✅ — EKS Foundation (complete)
Deployed containerized Flask app on EKS with:
- VPC with public/private subnets across 2 AZs
- EKS cluster with managed node group (t3.medium)
- AWS Load Balancer Controller via Helm + IRSA
- Kubernetes Deployment, Service, Ingress
- App running in private subnets, ALB in public subnets

## Phase 2 🚧 — Observability (next)
Prometheus + Grafana for metrics and dashboards.

## Phase 3 📋 — GitOps with ArgoCD (planned)
Replace GitHub Actions with ArgoCD for declarative deployments.

## Phase 4 📋 — Reusable Terraform Modules (planned)
Extract infrastructure into reusable modules any team can consume.