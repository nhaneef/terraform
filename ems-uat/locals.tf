provider "azurerm" {
  features {}
}

############################
# VARIABLES
############################

variable "location" {
  default = "Qatar Central"
}

variable "resource_group_name" {
  default = "rg-ems-network-uat-qc-001"
}

variable "vnet_name" {
  default = "vnet-ems-network-uat-qc-001"
}

variable "vnet_address_space" {
  default = ["172.22.209.0/24"]
}

variable "subnets" {
  type = map(object({
    address_prefix = string
  }))

 default = {
  snet-ems-paas-uat-qc-001 = {
    address_prefix = "172.22.209.0/27"
  }

  snet-ems-aks-uat-qc-001 = {
    address_prefix = "172.22.209.32/27"
  }

  snet-ems-iaas-uat-qc-001 = {
    address_prefix = "172.22.209.64/28"
  }

  snet-ems-db-uat-qc-001 = {
    address_prefix = "172.22.209.80/28"
  }

  snet-ems-apim-uat-qc-001 = {
    address_prefix = "172.22.209.96/28"
  }

  snet-ems-appgw-dev-qc-001 = {
    address_prefix = "172.22.209.128/26"
  }
}
}

############################
# RESOURCE GROUP
############################

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

############################
# VIRTUAL NETWORK
############################

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.vnet_address_space
}

############################
# ROUTE TABLE (UDR)
############################

resource "azurerm_route_table" "udr" {
  name                = "rt-prod-001"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  disable_bgp_route_propagation = false
}

############################
# ROUTES (EXAMPLE)
############################

resource "azurerm_route" "default_route" {
  name                   = "default-to-firewall"
  resource_group_name    = azurerm_resource_group.rg.name
  route_table_name       = azurerm_route_table.udr.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = "10.10.0.4" # Firewall IP
}

############################
# SUBNETS
############################

resource "azurerm_subnet" "subnets" {locals {
  sqlmi_nsg_name  = "nsg-sqlmi-ems-${var.environment}-qc-001"
  sqlmi_rt_name   = "rt-sqlmi-ems-${var.environment}-qc-001"

  sqlmi_rules = {
    health_probe = {
      name      = "mi-healthprobe"
      priority  = 100
      direction = "Inbound"
      source    = "AzureLoadBalancer"
      dest_port = "*"
      protocol  = "*"
    }

    tds_in = {
      name      = "allow-tds"
      priority  = 1000
      direction = "Inbound"
      source    = "VirtualNetwork"
      dest_port = "1433"
      protocol  = "Tcp"
    }

    deny_all_in = {
      name      = "deny-all-in"
      priority  = 4096
      direction = "Inbound"
      source    = "*"
      dest_port = "*"
      protocol  = "*"
      access    = "Deny"
    }
  }
}
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value.address_prefix]
}

############################
# ASSOCIATE UDR TO SUBNETS
############################

resource "azurerm_subnet_route_table_association" "assoc" {
  for_each = azurerm_subnet.subnets

  subnet_id      = each.value.id
  route_table_id = azurerm_route_table.udr.id
}