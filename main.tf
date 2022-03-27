//deploy baseline vpc
module "vpc" {
  source         = "./modules/vpc"
  azs            = local.azs
  env            = var.env
  id             = local.prefix
  prefix         = local.prefix
  project        = var.project
  region         = var.region
  vpc_cidr_block = var.vpc_cidr_block
}

module "eks" {
  source          = "./modules/eks"
  env             = var.env
  private_subnets = module.vpc.private_subnets
  project         = var.project
  region          = var.region
  vpc_id          = module.vpc.vpc_id
}

# module "consul_k8s" {
#   depends_on = [module.vpc, module.eks]
#   source = "./modules/consul_k8s"
#   env = var.env
#   root_domain = var.root_domain
#   id = local.prefix
#   org_name = var.org_name
#   project = var.project
#   subnets = module.vpc.private_subnets
#   tf_ip = local.tf_ip
#   region = var.region
# }

# module "consul_ec2" {
#     source = "./modules/consul"
#     env = var.env
#     root_domain = var.root_domain
#     id = local.prefix
#     org_name = var.org_name
#     project = var.project
#     subnets = module.vpc.private_subnets
#     tf_ip = local.tf_ip
#     region = var.region
# }

#############################
# supporting resources
#############################
locals {
  azs    = data.aws_availability_zones.azs.names
  prefix = random_string.prefix.result
  tf_ip  = "${chomp(data.http.tfip.body)}/32" #formatted for use in security groups
}

//availability zones
data "aws_availability_zones" "azs" {
  state = "available"
}

//idempotent id
resource "random_string" "prefix" {
  upper   = false
  special = false
  length  = 6
}

//public ip of tf workstation performing the run, adds to security groups for initial provisioning
data "http" "tfip" {
  url = "http://ipv4.icanhazip.com"
}

//write consul k/vs
# resource "consul_keys" "vpc" {
#     key {
#       path = "${var.env}/poc/vpc/vpc_id"
#       value = module.vpc.vpc_id
#     }
#     key {
#       path = "${var.env}/poc/vpc/private_subnets"
#       value = "${jsonencode(module.vpc.private_subnets)}"
#     }
# }
