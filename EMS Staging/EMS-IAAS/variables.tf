variable "admin_password" {
  description = "Local Administrator Password"
  type        = string
  sensitive   = true
}

variable "cmk_vault" {
  default= "kv-emsonp-cmk-stg-qc-001"
  type = string
  description = "cmk key vault"
  }

variable "sec_vault"{
default = "kv-emsonp-sec-stg-qc-001"
type = string
}

variable "private_dns_keyvault" {
  default = "privatelink.vaultcore.azure.net"
  type = string

}

variable "vnet_name" {
  default = "vnet-ems-onprem-network-stg-qc-001"
  type = string
}

# variable "snet_paas"{
# default = "snet-ems-onprem-paas-stg-qc-001"
# type = string
# }

variable "rg_network" {
  default = "rg-ems-onprem-network-stg-qc-001"
  type = string
}

