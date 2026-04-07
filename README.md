# AWS Platform Engineering

A production-grade internal developer platform built incrementally on AWS. This repo documents the journey from a simple EKS deployment to a full GitOps-driven platform with observability and reusable infrastructure modules.

---

## Phase 1 ✅ — EKS Foundation (complete)

**Goal:** Deploy a containerized app on Kubernetes with proper networking, security, and IAM.

**What I built:**
- VPC with public and private subnets across 2 availability zones
- EKS cluster (Kubernetes 1.31) with managed node group (t3.medium)
- NAT Gateway allowing private nodes to reach the internet without being publicly exposed
- AWS Load Balancer Controller installed via Helm with IRSA authentication
- Kubernetes Deployment, Service, and Ingress manifests
- App pods running in private subnets, ALB in public subnets
- OIDC provider and IAM Roles for Service Accounts (no stored credentials)

**Architecture:**
```
Internet
    ↓
ALB (public subnets: us-east-1a + us-east-1b)
    ↓ internal AWS network only
2 Flask pods (private subnets: us-east-1a + us-east-1b)
    ↓
EKS Node Group (t3.medium EC2 instances)
```

**Key design decisions:**
- Worker nodes in private subnets: no public IPs, not directly reachable from the internet
- ALB created automatically by the Load Balancer Controller reading Ingress annotations
- IRSA over stored access keys: pods get temporary credentials via OIDC
- 2 replicas across 2 AZs: if one availability zone goes down the app keeps running

**Tools:** Terraform, kubectl, Helm, eksctl, AWS CLI

---

**Problems faced in Phase 1:**

**Problem 1: Terraform binary committed to Git**

What happened: The .terraform folder containing the AWS provider binary (685MB) got committed. GitHub rejected the push because of the file size limit.

How I fixed it: Added a .gitignore file covering .terraform/, then used git rm --cached to remove it from tracking without deleting it locally.

Lesson: Always create .gitignore before running terraform init.

---

**Problem 2: Kubernetes version 1.29 AMI deprecated**

What happened: EKS refused to launch worker nodes because the AMI for Kubernetes 1.29 had been deprecated in us-east-1.

How I fixed it: Updated the cluster version to 1.31 in variables.tf.

Lesson: Always use a recent Kubernetes version. AWS deprecates old versions and removes their AMIs over time.

---

**Problem 3: Cannot skip minor versions when upgrading EKS**

What happened: After setting the version to 1.31, EKS blocked the upgrade because the cluster was already on 1.29. AWS only allows upgrading one minor version at a time.

How I fixed it: Ran terraform destroy and recreated the cluster fresh on 1.31 instead of trying to upgrade in place.

Lesson: EKS upgrades must go sequentially: 1.29 then 1.30 then 1.31. Skipping versions is not allowed because of API deprecations and component compatibility.

---

**Problem 4: Node group failing to launch due to EC2 restrictions**

What happened: The node group kept hitting CREATE_FAILED with an error saying t3.medium is not eligible for Free Tier. New AWS accounts have restrictions on launching non-free-tier instance types.

How I fixed it: Upgraded the AWS account to a paid support plan which lifted the EC2 launch restrictions.

Lesson: New AWS accounts may have EC2 launch restrictions even if quota shows 32 vCPUs available. Check account activation status if instances fail to launch.

---

**Problem 5: Terraform timeout on node group creation**

What happened: Closing the laptop mid-apply caused Terraform to time out after 20 minutes, leaving the node group in a failed state.

How I fixed it: Added a timeouts block to the node group resource setting create to 30 minutes.

Lesson: Always keep your machine running during terraform apply for EKS. Add explicit timeout blocks to avoid hitting the 20 minute default.

---

**Problem 6: Load Balancer Controller crashing on startup**

What happened: The controller pods kept restarting with CrashLoopBackOff. The logs showed it could not auto-detect the VPC ID from EC2 instance metadata.

How I fixed it: Explicitly passed the VPC ID during Helm install using --set vpcId=<your-vpc-id>.

Lesson: Always pass the VPC ID explicitly when installing the Load Balancer Controller. Auto-detection via instance metadata is unreliable and not recommended.

---

## Phase 2 📋 — Observability (planned)

**Goal:** Add full visibility into what is happening inside the cluster, including metrics, dashboards, and alerting.

**What I will build:**
- Prometheus: scrapes metrics from all pods and nodes automatically
- Grafana: dashboards showing CPU, memory, request rates, and error rates
- AlertManager: sends alerts when things go wrong like pod crashes or high CPU
- kube-state-metrics: exposes Kubernetes object state as metrics
- Node Exporter: exposes node-level metrics like disk, network, and CPU

**Why this matters:**
Without observability you are flying blind. You find out your app is down when users complain. With Prometheus and Grafana you see problems before users do, like rising error rates, memory leaks, or pods being killed due to memory limits.

**Installation plan:**
- Install kube-prometheus-stack via Helm (bundles Prometheus, Grafana, and AlertManager)
- Configure Grafana dashboards for Kubernetes cluster overview
- Set up alerts for pod restarts, high memory, and node pressure
- Expose Grafana via Ingress with ALB

**Tools:** Helm, Prometheus, Grafana, AlertManager

**Problems faced in Phase 2:** coming soon

---

## Phase 3 📋 — GitOps with ArgoCD (planned)

**Goal:** Replace manual kubectl apply with a system that automatically syncs the cluster to whatever is in the Git repo.

**What I will build:**
- ArgoCD: watches the Git repo and automatically deploys any changes
- ApplicationSet: manages multiple apps and environments from one config
- Sync policies: automatic vs manual promotion between environments
- Multi-environment setup: dev and prod namespaces with different configs

**Why this matters:**
Right now to deploy I run kubectl apply manually. GitOps flips this. The cluster watches Git and pulls changes automatically. This means:
- Every deployment is a Git commit, giving a full audit trail
- Rollback is just a git revert, simple and safe
- Nobody needs kubectl access to production, Git is the source of truth
- Drift detection: if someone manually changes something in the cluster, ArgoCD reverts it

**Tools:** ArgoCD, Helm, Git

**Problems faced in Phase 3:** coming soon

---

## Phase 4 📋 — Reusable Terraform Modules (planned)

**Goal:** Refactor all infrastructure into reusable modules so any team can deploy their own app with one config block.

**What I will build:**
- modules/eks-cluster: reusable EKS cluster with all best practices baked in
- modules/vpc: standardized VPC with public and private subnets, NAT, and tagging
- modules/k8s-app: deploys any app to EKS with Deployment, Service, and Ingress
- modules/observability: drops Prometheus and Grafana into any cluster
- Environment configs: environments/dev and environments/prod consuming the modules

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

And they get EKS deployment, ALB, and monitoring automatically. They do not need to know Kubernetes or AWS internals.

**Tools:** Terraform modules, Terragrunt (optional)

**Problems faced in Phase 4:** coming soon

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

- AWS CLI configured (aws configure)
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

# 3. Get your VPC ID
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=aws-platform-eks-vpc" --query "Vpcs[0].VpcId" --output text

# 4. Install Load Balancer Controller (replace YOUR_VPC_ID)
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=aws-platform-eks --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller --set vpcId=YOUR_VPC_ID

# 5. Deploy the app
kubectl apply -f phase-1-eks/k8s/

# 6. Get the URL
kubectl get ingress
```

## Destroy Infrastructure

Always delete Kubernetes resources before running terraform destroy. The Load Balancer Controller creates an ALB inside your VPC. If you run terraform destroy first, it will get stuck trying to delete the VPC because the ALB still exists inside it.

```bash
# 1. Delete K8s resources first (this removes the ALB)
kubectl delete -f phase-1-eks/k8s/

# 2. Then destroy the infrastructure
cd phase-1-eks/terraform
terraform destroy
```