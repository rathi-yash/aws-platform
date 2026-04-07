# AWS Platform Engineering

A production-grade internal developer platform built incrementally on AWS — documenting the journey from a simple EKS deployment to a full GitOps-driven platform with observability and reusable infrastructure modules.

---

## Phase 1 ✅ — EKS Foundation (complete)

**Goal:** Deploy a containerized app on Kubernetes with proper networking, security, and IAM.

**What we built:**
- VPC with public and private subnets across 2 availability zones
- EKS cluster (Kubernetes 1.31) with managed node group (t3.medium)
- NAT Gateway allowing private nodes to reach internet without public exposure
- AWS Load Balancer Controller installed via Helm with IRSA authentication
- Kubernetes Deployment, Service, and Ingress manifests
- App pods running in private subnets, ALB in public subnets
- OIDC provider + IAM Roles for Service Accounts (no stored credentials)

**Architecture:**
```
Internet
    ↓
ALB (public subnets — us-east-1a + us-east-1b)
    ↓ internal AWS network only
2 Flask pods (private subnets — us-east-1a + us-east-1b)
    ↓
EKS Node Group (t3.medium EC2 instances)
```

**Key design decisions:**
- Worker nodes in private subnets — no public IPs, not directly reachable from internet
- ALB created automatically by Load Balancer Controller reading Ingress annotations
- IRSA over stored access keys — pods get temporary credentials via OIDC
- 2 replicas across 2 AZs — if one availability zone goes down app keeps running

**Tools:** Terraform, kubectl, Helm, eksctl, AWS CLI

---

## Phase 2 📋 — Observability (planned)

**Goal:** Add full visibility into what's happening inside the cluster — metrics, dashboards, and alerting.

**What we will build:**
- Prometheus — scrapes metrics from all pods and nodes automatically
- Grafana — dashboards showing CPU, memory, request rates, error rates
- AlertManager — sends alerts when things go wrong (pod crash, high CPU etc.)
- kube-state-metrics — exposes Kubernetes object state as metrics
- Node Exporter — exposes node-level metrics (disk, network, CPU)

**Why this matters:**
Without observability you're flying blind. You find out your app is down when users complain. With Prometheus + Grafana you see problems before users do — rising error rates, memory leaks, pods being OOMKilled.

**Installation plan:**
- Install kube-prometheus-stack via Helm (bundles Prometheus + Grafana + AlertManager)
- Configure Grafana dashboards for Kubernetes cluster overview
- Set up alerts for pod restarts, high memory, node pressure
- Expose Grafana via Ingress with ALB

**Tools:** Helm, Prometheus, Grafana, AlertManager

---

## Phase 3 📋 — GitOps with ArgoCD (planned)

**Goal:** Replace manual `kubectl apply` with a system that automatically syncs the cluster to whatever is in the Git repo.

**What we will build:**
- ArgoCD — watches the Git repo and automatically deploys any changes
- ApplicationSet — manages multiple apps/environments from one config
- Sync policies — automatic vs manual promotion between environments
- Multi-environment setup — dev and prod namespaces with different configs

**Why this matters:**
Right now to deploy we run `kubectl apply` manually. GitOps flips this — the cluster watches Git and pulls changes automatically. This means:
- Every deployment is a Git commit — full audit trail
- Rollback = `git revert` — simple and safe
- No one needs kubectl access to production — Git is the source of truth
- Drift detection — if someone manually changes something in the cluster, ArgoCD reverts it

**Tools:** ArgoCD, Helm, Git

---

## Phase 4 📋 — Reusable Terraform Modules (planned)

**Goal:** Refactor all infrastructure into reusable modules so any team can deploy their own app with one config block.

**What we will build:**
- `modules/eks-cluster` — reusable EKS cluster with all best practices baked in
- `modules/vpc` — standardized VPC with public/private subnets, NAT, tagging
- `modules/k8s-app` — deploys any app to EKS (Deployment + Service + Ingress)
- `modules/observability` — drops Prometheus + Grafana into any cluster
- Environment configs — `environments/dev` and `environments/prod` consuming the modules

**Why this matters:**
This is the platform engineering differentiator. Instead of every team writing their own Terraform, they just do:

```hcl
module "my-app" {
  source      = "../modules/k8s-app"
  app_name    = "payment-service"
  image       = "my-image:latest"
  replicas    = 2
  environment = "prod"
}
```

And they get EKS deployment + ALB + monitoring automatically. They don't need to know Kubernetes or AWS internals.

**Tools:** Terraform modules, Terragrunt (optional)

---

## Project Structure

```
aws-platform/
├── phase-1-eks/
│   ├── terraform/          # EKS cluster, VPC, IAM, OIDC
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── vpc.tf
│   │   ├── iam.tf
│   │   └── eks.tf
│   └── k8s/                # Kubernetes manifests
│       ├── deployment.yaml
│       ├── service.yaml
│       └── ingress.yaml
├── phase-2-observability/  # coming soon
├── phase-3-gitops/         # coming soon
├── phase-4-modules/        # coming soon
└── README.md
```

## Prerequisites

- AWS CLI configured (`aws configure`)
- Terraform v1.0+
- kubectl
- Helm
- eksctl
- Docker

## Quick Start (Phase 1)

```bash
# 1. Provision infrastructure
cd phase-1-eks/terraform
terraform init
terraform apply

# 2. Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name aws-platform-eks

# 3. Install Load Balancer Controller
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=aws-platform-eks --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller --set vpcId=<your-vpc-id>

# 4. Deploy the app
kubectl apply -f phase-1-eks/k8s/

# 5. Get the URL
kubectl get ingress
```

## Destroy Infrastructure

```bash
kubectl delete -f phase-1-eks/k8s/
cd phase-1-eks/terraform
terraform destroy
```