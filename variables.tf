variable "resoure_group_name" {
  description = "Name of the resource group"
  default = "fp_williams_RG"
}

variable "location" {
  description = "Location of the resource"
  default     = "West Europe"
}

variable "application_name" {
  description = "Name of the application"
  default = "helloword_app"
}

variable "ip_name" {
  description = "Name of the public ip"
  default = "fp_williams_IP"
}
variable "password" {}
variable "username" {}