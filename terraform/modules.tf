module "network" {
  source = "./modules/network"
}

module "eks_cluster" {
  source             = "./modules/cluster"
  kubernetes_version = "1.29"
  private_subnet_ids = module.network.subnets_app_ids
  vpc_id             = module.network.vpc_id
  ssh_key_name       = "airflow-ubuntu"
}
