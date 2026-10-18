variable "location" {
  default = "qatarcentral"
}

variable "resource_group_name" {
  default = "rg-terraform-demo"
}

variable "vnet_name" {
  default = "vnet-demo"
}

variable "vnet_address_space" {
  default = ["10.10.0.0/16"]
}

variable "subnet_name" {
  default = "subnet-demo"
}

variable "subnet_prefix" {
  default = ["10.10.1.0/24"]
}

variable "subnet_name1" {
  default = "subnet-demo1"
}

variable "subnet_prefix1" {
  default = ["10.10.2.0/24"]
}

variable "subnet_name2" {
  default = "subnet-demo2"
}

variable "subnet_prefix2" {
  default = ["10.10.3.0/24"]
}
