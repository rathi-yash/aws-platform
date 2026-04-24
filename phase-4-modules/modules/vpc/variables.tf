variable "cluster_name" {
    description = "Name of the EKS cluster"
    type = string
}

variable "vpc_cidr" {
    description = "CIDR block for the VPC"
    type = string
    default = "10.0.0.0/16"
}

variable "aws_region" {
    description = "AWS region"
    type = string
    default = "us-east-1"
}

variable "environment" {
    description = "Environment name (dev or prod)"
    type = string
}