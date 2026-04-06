# EKS CLUSTER
resource "aws_eks_cluster" "main" {
    name = var.cluster_name
    version = var.cluster_version
    role_arn = aws_iam_role.cluster.arn

    vpc_config {
        subnet_ids = [
            aws_subnet.public_a.id,
            aws_subnet.public_b.id,
            aws_subnet.private_a.id,
            aws_subnet.private_b.id
            ]
            endpoint_private_access = true
            endpoint_public_access = true
    }

    depends_on = [
        aws_iam_role_policy_attachment.cluster_policy
    ]

    tags = {
        Name = var.cluster_name
    }
}

# NODE GROUP
resource "aws_eks_node_group" "main" {
    cluster_name = aws_eks_cluster.main.name
    node_group_name = "${var.cluster_name}-node-group"
    node_role_arn = aws_iam_role.node.arn
    subnet_ids = [
        aws_subnet.public_a.id,
        aws_subnet.public_b.id
    ]

    instance_types = [var.node_instance_type]

    scaling_config {
        desired_size = var.node_desired_capacity
        min_size = var.node_min_capacity
        max_size = var.node_max_capacity
    }

    update_config {
        max_unavailable = 1
    }

    depends_on = [
        aws_iam_role_policy_attachment.node_policy,
        aws_iam_role_policy_attachment.node_ecr_policy,
        aws_iam_role_policy_attachment.node_cni_policy
    ]

    tags = {
        Name = "${var.cluster_name}-node-group"
    }
}