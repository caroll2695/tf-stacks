//global
variable "org_name" {
  default = "Apex Crypto"
}
variable "project" {
  default = "devops-test"
}
variable "region" {
  default = "us-west-1"
}
variable "env" {
  default = "devops-test"
}
variable "root_domain" {
  default     = "apexcrypto.com"
  description = "DNS zone for services ot be launched in"
}


//vpc
variable "vpc_cidr_block" {
  default = "10.10.0.0/16"
}
