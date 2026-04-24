variable "aws_region" {
  default = "us-east-1"
}

variable "cluster_name" {
  default = "aws-platform-prod"
}

variable "environment" {
  default = "prod"
}

variable "vpc_cidr" {
  default = "10.1.0.0/16"
}

variable "node_instance_type" {
  default = "t3.medium"
}

variable "node_desired_capacity" {
  default = 3
}

variable "node_min_capacity" {
  default = 2
}

variable "node_max_capacity" {
  default = 5
}