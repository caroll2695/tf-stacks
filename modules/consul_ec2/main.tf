//build consul server ami
resource "packer_image" "consul_server" {
    file = "${path.module}/packer/consul_server.pkr.hcl"
    variables = {
        region = var.region
        public_url = local.consul_svc_url
        instance_type = "t3.medium"
        consul_version = "1.11.2"
        agent_type = "server"
    }
}

resource "aws_launch_template" "consul" {
  name = "consul-srv-${var.env}-${var.id}"

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 120
    }
  }
  ebs_optimized = true
  image_id = packer_image.consul_server.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t3.medium"
  key_name = "test"

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "consul-${var.env}"
    }
  }

  user_data = ""
}



#############################
# supporting resources
#############################
locals {
  consul_svc_url = "consul${var.id}-${var.env}.${var.root_domain}"
  r53_zone_id    = data.aws_route53_zone.root.zone_id
  ca_public_key = tls_self_signed_cert.ca.cert_pem
  cert_pem = tls_locally_signed_cert.cert.cert_pem
  cert_key = tls_private_key.cert.private_key_pem
}

data "aws_route53_zone" "root" {
  name = "${var.root_domain}."
}

terraform {
  required_providers {
    packer = {
      source = "toowoxx/packer"
    }
  }
}
