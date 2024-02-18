resource "random_string" "random" {
  length  = 10
  special = false
}

resource "aws_eks_cluster" "eks_cluster_devops" {
  name     = "cluster-devops-${random_string.random.result}"
  role_arn = aws_iam_role.eks_cluster_role.arn
  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    subnet_ids              = var.private_subnet_ids
    security_group_ids = [
      aws_security_group.eks_cluster_sg_control_plane.id
    ]
  }
  version = var.kubernetes_version
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }
  encryption_config {
    provider {
      key_arn = aws_kms_key.eks_cluster_encryption_key.arn
    }
    resources = ["secrets"]
  }
}

resource "aws_security_group" "eks_cluster_sg_control_plane" {
  name        = "eks-sg-controlplane-${random_string.random.result}"
  description = "security group for cluster-devops-${random_string.random.result} eks"
  vpc_id      = var.vpc_id
  tags = {
    "Name" = "eks-sg-controlplane-${random_string.random.result}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ingress_local_ipv4_traffic" {
  security_group_id            = aws_security_group.eks_cluster_sg_control_plane.id
  referenced_security_group_id = aws_security_group.eks_cluster_sg_control_plane.id
  ip_protocol                  = -1
}

resource "aws_vpc_security_group_egress_rule" "allow_egress_ipv4_traffic" {
  security_group_id = aws_security_group.eks_cluster_sg_control_plane.id
  ip_protocol       = -1
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_kms_key" "eks_cluster_encryption_key" {
  description  = "Encryption of secrets on kubernetes cluster"
  key_usage    = "ENCRYPT_DECRYPT"
  multi_region = false
}

resource "aws_eks_node_group" "eks_cluster_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster_devops.name
  node_group_name = "default"
  node_role_arn   = aws_iam_role.eks_cluster_node_group.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = ["t3.medium"]
  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
  update_config {
    max_unavailable = 1
  }
  remote_access {
    ec2_ssh_key = var.ssh_key_name
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_role-AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks_cluster_role-AmazonEKSWorkerNodePolicy
  ]
}
