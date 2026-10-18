variable "location" {
  description = "Azure Region"
  type        = string
  default     = "qatarcentral"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "address_space" {
  type = list(string)
}

variable "sqlmi_subnet_cidr" {
  type = string
}

variable "tags" {
  type = map(string)
}
