variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "role_name" {
  description = "Name for the IAM role"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider from EKS module"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the OIDC provider from EKS module"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace of the service account"
  type        = string
}

variable "service_account_name" {
  description = "Name of the Kubernetes service account"
  type        = string
}

variable "policy_arns" {
  description = "List of IAM policy ARNs to attach to the role"
  type        = list(string)
}