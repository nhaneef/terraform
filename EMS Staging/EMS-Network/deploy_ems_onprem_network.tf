terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "80936d31-4fa0-47d4-9850-4c2814100866"
}

provider "azurerm" {
  alias = "hub"

  features {}

  subscription_id = var.hub_subscription_id
}
variable "location" {
  default = "qatarcentral"
}

variable "hub_subscription_id" {
  description = "Hub subscription ID"
  type        = string
}

variable "hub_resource_group_name" {
  description = "Hub Resource Group"
  type        = string
}

variable "hub_vnet_name" {
  description = "Hub VNet Name"
  type        = string
  default     = "vnet-connectivity-qc-001"
}

resource "azurerm_resource_group" "network_rg" {
  name     = "rg-ems-onprem-network-stg-qc-001"
  location = var.location
}


# provider "azurerm" {
#   features {}

#   subscription_id = "80936d31-4fa0-47d4-9850-4c2814100866"
# }

# provider "azurerm" {
#   alias           = "hub"
#   features        = {}
#   subscription_id = var.hub_subscription_id
# }

# variable "hub_subscription_id" {
#   description = "Connectivity Hub Subscription ID"
#   type        = string
# }

# variable "hub_resource_group_name" {
#   description = "Hub Resource Group Name"
#   type        = string
# }

# variable "hub_vnet_name" {
#   description = "Hub VNet Name"
#   type        = string
#   default     = "vnet-connectivity-qc-001"
# }

# variable "location" {
#   type    = string
#   default = "qatarcentral"
# }

# resource "azurerm_resource_group" "network_rg" {
#   name     = "rg-ems-onprem-network-stg-qc-001"
#   location = var.location
# }

resource "azurerm_virtual_network" "spoke_vnet" {
  name                = "vnet-ems-onprem-network-stg-qc-001"
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name

  address_space = [
    "172.30.232.128/25"
  ]
}

resource "azurerm_subnet" "paas" {
  name                 = "snet-ems-onprem-paas-stg-qc-001"
  resource_group_name  = azurerm_resource_group.network_rg.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes     = ["172.30.232.128/28"]
}

resource "azurerm_subnet" "fe" {
  name                 = "snet-ems-onprem-fe-stg-qc-001"
  resource_group_name  = azurerm_resource_group.network_rg.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes     = ["172.30.232.144/28"]
}

resource "azurerm_subnet" "db" {
  name                 = "snet-ems-onprem-db-stg-qc-004"
  resource_group_name  = azurerm_resource_group.network_rg.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes     = ["172.30.232.160/28"]
}

resource "azurerm_subnet" "be" {
  name                 = "snet-ems-onprem-be-stg-qc-001"
  resource_group_name  = azurerm_resource_group.network_rg.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes     = ["172.30.232.176/28"]
}

data "azurerm_virtual_network" "hub_vnet" {
  provider = azurerm.hub

  name                = var.hub_vnet_name
  resource_group_name = var.hub_resource_group_name
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  provider = azurerm.hub

  name                      = "peer-vnet-connectivity-qc-001-to-vnet-ems-onprem-network-stg-qc-001"
  resource_group_name       = data.azurerm_virtual_network.hub_vnet.resource_group_name
  virtual_network_name      = data.azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.spoke_vnet.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "vnet-ems-onprem-network-stg-qc-001-to-vnet-connectivity-qc-001"
  resource_group_name       = azurerm_resource_group.network_rg.name
  virtual_network_name      = azurerm_virtual_network.spoke_vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.hub_vnet.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = true

  depends_on = [
    azurerm_virtual_network_peering.hub_to_spoke
  ]
}