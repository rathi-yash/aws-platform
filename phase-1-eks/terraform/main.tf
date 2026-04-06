terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }

        kubernetes = {
            source = "hashicorp/kubernetes"
            version = "~> 2.0"
        }
    }
}

provider "aws" {
    region = var.aws_region
}

provider "kubernetes" {
    host = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec{
        api_version = "client.authenticate.k8s.io/v1beta1"
        args = ["eks", "get-token", "--cluster-name", var.cluster_name]
        command = "aws"
    }
}