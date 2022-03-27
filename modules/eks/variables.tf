variable "project" {}
variable "cluster_version" {
    default = "1.21"
}
variable "env" {}
variable "vpc_id" {}
variable "private_subnets" {}
variable "instance_type" {
    default = "t3.medium"
}
variable "volume_size" {
    default = 150
}
variable "volume_type" {
    default = "gp2"
}
variable "region"{}
