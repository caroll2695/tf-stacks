module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.project
  cidr = var.vpc_cidr_block

  azs             = var.azs
  private_subnets = ["10.10.100.0/24","10.10.101.0/24"]
  public_subnets  = ["10.10.0.0/27","10.10.1.0/27"]

  enable_nat_gateway = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.project}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.project}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }

  tags = {
    Environment = var.env
    Id = var.id
  }
}


#############################
# supporting resources
#############################
locals {
}
