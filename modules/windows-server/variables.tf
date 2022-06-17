variable "windows_instance_type" {
  type        = string
  description = "EC2 instance type for Windows Server"
  default     = "t2.micro"
}
variable "windows_associate_public_ip_address" {
  type        = bool
  description = "Associate a public IP address to the EC2 instance"
  default     = true
}
variable "windows_root_volume_size" {
  type        = number
  description = "Volumen size of root volumen of Windows Server"
  default     = "30"
}
variable "windows_data_volume_size" {
  type        = number
  description = "Volumen size of data volumen of Windows Server"
  default     = "10"
}
variable "windows_root_volume_type" {
  type        = string
  description = "Volumen type of root volumen of Windows Server."
  default     = "gp2"
}
variable "windows_data_volume_type" {
  type        = string
  description = "Volumen type of data volumen of Windows Server."
  default     = "gp2"
}
variable "windows_instance_name" {
  type        = string
  description = "EC2 instance name for Windows Server"
  default     = "tfwinsrv01"
}

variable "region" {}
variable "env" {}
variable "project" {}
variable "vpc_id" {}
variable "private_subnets" {}
variable "key_pair_name" {}
variable "my_ip" {}
