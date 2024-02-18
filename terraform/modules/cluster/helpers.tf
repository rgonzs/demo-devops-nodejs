data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.eks_cluster_devops.identity.0.oidc.0.issuer
}