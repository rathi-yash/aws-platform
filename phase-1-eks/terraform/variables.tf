variable "aws_region" {
    default = "us-east-1"
}

variable "cluster_name" {
    default = "aws-platform-eks"
}

variable "cluster_version" {
    default = "1.31"
}

variable "app_name" {
    default = "flask-app"
}

variable "container_port" {
    default = 5000
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