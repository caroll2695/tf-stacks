module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.20.0"
  cluster_name    = var.project
  cluster_version = "1.21"

  vpc_id  = var.vpc_id
  subnets = var.private_subnets

  manage_cluster_iam_resources = false
  cluster_iam_role_name        = aws_iam_role.control-plane.name
  manage_worker_iam_resources  = false
  workers_role_name            = aws_iam_role.nodes.name

  cluster_create_security_group = false
  cluster_security_group_id     = aws_security_group.control-plane-additional.id
  worker_create_security_group  = false
  worker_security_group_id      = aws_security_group.worker-nodes.id

  manage_aws_auth                   = false
  create_fargate_pod_execution_role = false
  write_kubeconfig                  = false

  depends_on = [aws_iam_role.control-plane]
}

resource "aws_eks_node_group" "general" {
  node_group_name = "general"
  cluster_name    = var.project
  node_role_arn   = aws_iam_role.nodes.arn

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.medium"]
  disk_size      = 150

  subnet_ids = var.private_subnets

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }

  remote_access {
    ec2_ssh_key               = aws_key_pair.deploy.key_name
    source_security_group_ids = [module.eks.cluster_primary_security_group_id]
  }
}


##################################
# supporting resources
##################################

#assign local variables from lookups
locals {}

//create kms encryption key for cluster
resource "aws_kms_key" "eks" {
  description = "eks_encryption"
}

//create ssh key
resource "tls_private_key" "ssh" {
  algorithm   = "RSA"
}
resource "aws_key_pair" "deploy" {
  key_name   = "${var.env}-nodes"
  public_key = tls_private_key.ssh.public_key_openssh
}
resource "local_file" "ssh_key" {
    filename = "./${var.project}.pem"
    content = tls_private_key.ssh.private_key_pem
}
