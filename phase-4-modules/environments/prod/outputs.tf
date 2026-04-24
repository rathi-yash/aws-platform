output "cluster_name" {
  value = module.eks.cluster_name
}

output "configure_kubectl" {
  value = module.eks.configure_kubectl
}

output "vpc_id" {
  value = module.vpc.vpc_id
}