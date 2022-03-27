variable "vpc_cidr_block" {}
variable "env" {}
variable "project" {}
variable "region" {}
variable "prefix" {}
variable "azs" {}
variable "id" {}
variable "private_subnet_mask_bits" {
    default = 8
    description = "Number of bits to add to the default vpc subnet mask. Ex: /16 vpc mask + 8 bits = /24 subnets"
}
variable "public_subnet_mask_bits" {
    default = 8
    description = "Number of bits to add to the default vpc subnet mask. Ex: /16 vpc mask + 8 bits = /24 subnets"
}
