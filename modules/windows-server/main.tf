# Create EC2 Instance
resource "aws_instance" "windows-server" {
  ami                    = data.aws_ami.windows-2019.id
  instance_type          = var.windows_instance_type
  subnet_id              = var.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.aws-windows-sg.id]
  source_dest_check      = false
  key_name               = var.key_pair_name
  user_data              = data.template_file.windows-userdata.rendered

  # root disk
  root_block_device {
    volume_size           = var.windows_root_volume_size
    volume_type           = var.windows_root_volume_type
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name        = "windows-server-vm-${var.project}"
    Environment = var.env
  }
}

# Define the security group for the Windows server
resource "aws_security_group" "aws-windows-sg" {
  name        = "windows-sg"
  description = "Allow incoming connections"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}"]
    description = "Allow incoming HTTP connections"
  }
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}"]
    description = "Allow incoming RDP connections"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "windows-sg-${var.project}"
  }
}
