resource "helm_release" "aws-load-balancer-controller" {
  depends_on = [kubernetes_service_account.aws-load-balancer-controller]
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  set {
    name  = "clusterName"
    value = aws_eks_cluster.eks_cluster_devops.name
  }
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
}

resource "kubernetes_service_account" "aws-load-balancer-controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/component" : "controller"
      "app.kubernetes.io/name" : "aws-load-balancer-controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" : aws_iam_role.loadbalancer_controller_role.arn
    }
  }
}
