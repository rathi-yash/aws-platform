variable "aws_region" {
  default = "us-east-1"
}

variable "cluster_name" {
  default = "aws-platform-dev"
}

variable "environment" {
  default = "dev"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "node_instance_type" {
  default = "t3.medium"
}

variable "node_desired_capacity" {
  default = 2
}

variable "node_min_capacity" {
  default = 1
}

variable "node_max_capacity" {
  default = 3
}