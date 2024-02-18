resource "aws_eks_addon" "coredns_addon" {
  cluster_name                = aws_eks_cluster.eks_cluster_devops.name
  addon_name                  = "coredns"
  addon_version               = "v1.11.1-eksbuild.6"
  resolve_conflicts_on_update = "PRESERVE"
  depends_on                  = [aws_eks_node_group.eks_cluster_node_group]
}

resource "aws_eks_addon" "kube-proxy_addon" {
  cluster_name                = aws_eks_cluster.eks_cluster_devops.name
  addon_name                  = "kube-proxy"
  addon_version               = "v1.29.0-eksbuild.1"
  resolve_conflicts_on_update = "PRESERVE"
}

resource "aws_eks_addon" "vpc-cni_addon" {
  cluster_name                = aws_eks_cluster.eks_cluster_devops.name
  addon_name                  = "vpc-cni"
  addon_version               = "v1.16.2-eksbuild.1"
  resolve_conflicts_on_update = "PRESERVE"
}

resource "aws_eks_addon" "identity_addon" {
  cluster_name                = aws_eks_cluster.eks_cluster_devops.name
  addon_name                  = "eks-pod-identity-agent"
  addon_version               = "v1.1.0-eksbuild.1"
  resolve_conflicts_on_update = "PRESERVE"
}
