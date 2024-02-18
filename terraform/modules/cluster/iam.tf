data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name               = "eks-cluster-role-${random_string.random.result}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "eks_cluster_role-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "eks_cluster_role-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks_cluster_node_group" {
  name               = "eks-cluster-role-node-group-${random_string.random.result}"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_role_policy_attachment" "eks_cluster_role-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_cluster_node_group.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_role-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_cluster_node_group.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_role-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_cluster_node_group.name
}

# Roles creados para poder instalar el Load Balancer controller en EKS.

locals {
  account_id = data.aws_caller_identity.current.account_id
  oidc_id    = element(split("/", aws_iam_openid_connect_provider.eks_cluster_provider.id), length(split("/", aws_iam_openid_connect_provider.eks_cluster_provider.id)) - 1)
}

resource "aws_iam_openid_connect_provider" "eks_cluster_provider" {
  url             = aws_eks_cluster.eks_cluster_devops.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates.0.sha1_fingerprint]
}

resource "aws_iam_policy" "loadbalancer_controller_policy" {
  name   = "AWSLoadBalancerControllerIAMPolicy-${random_string.random.result}"
  policy = file("${path.module}/loadbalancer_controller_iam_policy.json")
}


data "aws_iam_policy_document" "load_balancer_trust_policy" {
  depends_on = [aws_iam_openid_connect_provider.eks_cluster_provider]
  statement {
    effect = "Allow"
    principals {
      type = "Federated"
      identifiers = [
        "arn:aws:iam::${local.account_id}:oidc-provider/oidc.eks.${data.aws_region.current.name}.amazonaws.com/id/${local.oidc_id}"
      ]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "oidc.eks.${data.aws_region.current.name}.amazonaws.com/id/${local.oidc_id}:aud"
      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "oidc.eks.${data.aws_region.current.name}.amazonaws.com/id/${local.oidc_id}:sub"
      values = [
        "system:serviceaccount:kube-system:aws-load-balancer-controller"
      ]
    }
  }
}

resource "aws_iam_role" "loadbalancer_controller_role" {
  name               = "AmazonEKSLoadBalancerControllerRole-${random_string.random.result}"
  assume_role_policy = data.aws_iam_policy_document.load_balancer_trust_policy.json
}

resource "aws_iam_role_policy_attachment" "loadbalancer_controller_role_attachment" {
  role       = aws_iam_role.loadbalancer_controller_role.name
  policy_arn = aws_iam_policy.loadbalancer_controller_policy.arn
}
