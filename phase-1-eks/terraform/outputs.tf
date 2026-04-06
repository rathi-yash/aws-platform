output "cluster_name" {
    value = aws_eks_cluster.main.name
    description = "EKS cluster name"
}

output "cluster_endpoint" {
    value = aws_eks_cluster.main.endpoint
    description = "EKS cluster API endpoint"
}

output "cluster_version" {
    value = aws_eks_cluster.main.version
    description = "Kubernetes version running on the cluster"
}

output "node_group_name" {
    value = aws_eks_node_group.main.node_group_name
    description = "EKS node group name"
}

output "configure_kubectl" {
    value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${var.cluster_name}"
    description = "Command to configure kubectl to talk to this cluster"
}