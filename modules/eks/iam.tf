resource "aws_iam_policy" "elb-sl-role-creation" {
  name        = "${var.project}-eks-elb-sl-role-creation"
  description = "Permissions for EKS to create AWSServiceRoleForElasticLoadBalancing service-linked role"
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Sid      = ""
          Effect   = "Allow"
          Resource = "*"
          Action = [
            "ec2:DescribeInternetGateways",
            "ec2:DescribeAddresses",
            "ec2:DescribeAccountAttributes",
          ]
        }
      ]
    }
  )
}

resource "aws_iam_role" "control-plane" {
  name                  = "${var.project}-eks-control-plane"
  force_detach_policies = true
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "EKSClusterAssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "eks.amazonaws.com"
          }
          Action = "sts:AssumeRole"
        }
      ]
    }
  )
  managed_policy_arns = [
    aws_iam_policy.elb-sl-role-creation.arn,
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
  ]
}

resource "aws_iam_role" "nodes" {
  name                  = "${var.project}-eks-nodes"
  force_detach_policies = true
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "EKSWorkerAssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "ec2.amazonaws.com"
          }
          Action = "sts:AssumeRole"
        }
      ]
    }
  )
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
  ]
  inline_policy {
    name = "param-store"
    policy = jsonencode({
      Version = "2012-10-17"
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : ["ssm:GetParametersByPath"],
          "Resource" : [
            "arn:aws:ssm:${var.region}:${local.account_id}:parameter/rds*",
            "arn:aws:ssm:${var.region}:${local.account_id}:parameter/vsbcrypto*"
          ]
        }
      ]
    })
  }
}


locals{
  account_id = data.aws_caller_identity.current.account_id
}

#############################
# suporting resources
############################
//loookup account id
data "aws_caller_identity" "current" {}
