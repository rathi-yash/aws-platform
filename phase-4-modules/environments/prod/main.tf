terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

# VPC Module
module "vpc" {
  source       = "../../modules/vpc"
  cluster_name = var.cluster_name
  aws_region   = var.aws_region
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
}

# EKS Module
module "eks" {
  source       = "../../modules/eks"
  cluster_name = var.cluster_name
  aws_region   = var.aws_region
  environment  = var.environment

  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = [module.vpc.public_subnet_a_id, module.vpc.public_subnet_b_id]
  private_subnet_ids = [module.vpc.private_subnet_a_id, module.vpc.private_subnet_b_id]

  node_instance_type    = var.node_instance_type
  node_desired_capacity = var.node_desired_capacity
  node_min_capacity     = var.node_min_capacity
  node_max_capacity     = var.node_max_capacity
}

# IRSA for Load Balancer Controller
module "irsa_lbc" {
  source       = "../../modules/irsa"
  cluster_name = var.cluster_name
  environment  = var.environment

  role_name            = "lbc-role"
  oidc_provider_arn    = module.eks.oidc_provider_arn
  oidc_provider_url    = module.eks.oidc_provider_url
  namespace            = "kube-system"
  service_account_name = "aws-load-balancer-controller"
  policy_arns          = [aws_iam_policy.lbc.arn]
}

# LBC IAM Policy
data "http" "lbc_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"
}

resource "aws_iam_policy" "lbc" {
  name   = "${var.cluster_name}-lbc-policy"
  policy = data.http.lbc_iam_policy.response_body
}