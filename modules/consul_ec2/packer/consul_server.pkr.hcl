locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

variable "region" {
  type = string
}
variable "public_url" {
  type = string
}
variable "instance_type" {
    type = string
}
variable "consul_version" {
    type = string
    default = "1.11.2"
}
variable "agent_type" {
    type = string
}

source "amazon-ebs" "base" {
  ami_name      = "consul-srv-${local.timestamp}"
  instance_type = var.instance_type
  region        = var.region

  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-2.0.*-x86_64-gp2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  ssh_username = "ec2-user"
}

build {
  sources = ["source.amazon-ebs.base"]

  provisioner "shell" {
    inline = [
        "sudo yum update -y",
        "sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo",
        "sudo yum -y install consul-${var.consul_version}",
    ]
  }

  post-processor "manifest" {
    output = "manifest.json"
  }
}
