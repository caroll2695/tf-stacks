resource "aws_security_group" "control-plane-additional" {
  name        = "${var.project}-control-plane-additional"
  description = "EKS cluster control plane security group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow cluster control plane egress access to the internet"
  }

  tags = { "Name" = "${var.project}-control-plane-additional" }
}

# this has to be separated out as to not cause a reference cycle
resource "aws_security_group_rule" "worker-nodes-to-control-plane-additional" {
  security_group_id        = aws_security_group.control-plane-additional.id
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.worker-nodes.id
  description              = "Allow worker node pods to communicate with the EKS cluster API"
}

resource "aws_security_group" "worker-nodes" {
  name        = "${var.project}-worker-nodes"
  description = "Worker (non-managed) nodes security group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow worker nodes all egress to the internet"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    self        = true
    description = "Allow worker nodes to communicate with each other"
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.control-plane-additional.id]
    description     = "Allow worker node pods running extension API servers on port 443 to receive communication from cluster control plane"
  }

  ingress {
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.control-plane-additional.id]
    description     = "Allow worker node pods to receive communication from the cluster control plane"
  }

  tags = {
    "Name"                             = "${var.project}-worker-nodes"
    "kubernetes.io/cluster/${var.project}" = "owned"
  }
}
