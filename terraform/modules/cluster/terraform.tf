terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.26.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "arn:aws:eks:us-east-1:320488417544:cluster/cluster-devops-O7NbsaE1pI"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    config_context = "arn:aws:eks:us-east-1:320488417544:cluster/cluster-devops-O7NbsaE1pI"
  }
}