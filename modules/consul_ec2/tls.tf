//create tls private ca
resource "tls_private_key" "ca" {
  algorithm   = "RSA"
  rsa_bits    = "2048"
}

resource "tls_self_signed_cert" "ca" {
  key_algorithm     = "RSA"
  private_key_pem   = tls_private_key.ca.private_key_pem
  is_ca_certificate = true

  validity_period_hours = 8766
  allowed_uses          = [
    "cert_signing",
    "key_encipherment",
    "digital_signature",
  ]

  subject {
    common_name  = local.consul_svc_url
    organization = var.org_name
  }
}


//create self-signed tls cert using ca cert
resource "tls_private_key" "cert" {
  algorithm   = "RSA"
  rsa_bits    = 2048
}

resource "tls_cert_request" "cert" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.cert.private_key_pem
  dns_names    = ["${local.consul_svc_url}"]
  subject {
    common_name  = local.consul_svc_url
    organization = var.org_name
  }
}

resource "tls_locally_signed_cert" "cert" {
  cert_request_pem = tls_cert_request.cert.cert_request_pem
  ca_key_algorithm   = "RSA"
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem
  validity_period_hours = 8677
  allowed_uses          = [
      "digital_signature",
      "content_commitment",
      "key_encipherment",
      "data_encipherment",
      "key_agreement",
      "cert_signing",
  ]
}
