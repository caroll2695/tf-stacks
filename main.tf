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

module "windows-server" {
  source          = "./modules/windows-server"
  region          = var.region
  env             = var.env
  project         = var.project
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  key_pair_name   = aws_key_pair.ssh_key.key_name
  my_ip           = local.tf_ip
}

module "linux-server" {
  source          = "./modules/linux-server"
  region          = var.region
  env             = var.env
  project         = var.project
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets
  key_pair_name   = aws_key_pair.ssh_key.key_name
  my_ip           = local.tf_ip
}

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

//create ssh key
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
}
resource "aws_key_pair" "ssh_key" {
  key_name   = "gd-${var.project}-workers"
  public_key = tls_private_key.ssh.public_key_openssh
}
resource "local_file" "ssh_key" {
  filename = "./${var.project}.pem"
  content  = tls_private_key.ssh.private_key_pem
}
