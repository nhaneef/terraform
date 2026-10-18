terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "2e82a792-4c3b-438a-99ff-46b6453e329d"
}

provider "azurerm" {
  alias = "connectivity"
  features {}
  subscription_id = "845b4977-4f63-4971-a926-dd691fd2e258"
}

provider "azurerm" {
  alias = "dns"
  features {}
  subscription_id = "845b4977-4f63-4971-a926-dd691fd2e258"
}

data "azurerm_client_config" "current" {}

locals {
  windows_license_type = "Windows_Server"
}

variable "admin_password" {
  description = "Local administrator password"
  type        = string
  sensitive   = true
}


##################################################
# Resource Group
##################################################

resource "azurerm_resource_group" "rgstg" {
  name     = "rg-moph-dhp-stg-qc-001"
  location = "Qatar Central"
}

##################################################
# Virtual Network and Subnets
##################################################

resource "azurerm_virtual_network" "vnetstg" {
  name                = "vnet-moph-dhp-stg-qc-001"
  resource_group_name = azurerm_resource_group.rgstg.name
  location            = azurerm_resource_group.rgstg.location
  address_space       = ["172.30.236.64/26"]
}

resource "azurerm_subnet" "app" {
  name                 = "snet-moph-dhp-stg-app-qc-001"
  virtual_network_name = azurerm_virtual_network.vnetstg.name
  resource_group_name  = azurerm_resource_group.rgstg.name
  address_prefixes     = ["172.30.236.64/28"]
}

resource "azurerm_subnet" "wfe" {
  name                 = "snet-moph-dhp-stg-wfe-qc-001"
  virtual_network_name = azurerm_virtual_network.vnetstg.name
  resource_group_name  = azurerm_resource_group.rgstg.name
  address_prefixes     = ["172.30.236.80/28"]
}

resource "azurerm_subnet" "pe" {
  name                              = "snet-moph-dhp-stg-pe-qc-001"
  virtual_network_name              = azurerm_virtual_network.vnetstg.name
  resource_group_name               = azurerm_resource_group.rgstg.name
  address_prefixes                  = ["172.30.236.96/28"]
  private_endpoint_network_policies = "Disabled"
}
###########################################################
# Route Table

resource "azurerm_route_table" "rt_app" {
  name                = "rt-moph-dhp-stg-app-qc-001"
  location            = azurerm_resource_group.rgstg.location
  resource_group_name = azurerm_resource_group.rgstg.name

  route {
    name                   = "default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "172.28.136.71"
  }
}

resource "azurerm_subnet_route_table_association" "rt_app_assoc" {
  subnet_id      = azurerm_subnet.app.id
  route_table_id = azurerm_route_table.rt_app.id
}


resource "azurerm_route_table" "rt_wfe" {
  name                = "rt-moph-dhp-stg-wfe-qc-001"
  location            = azurerm_resource_group.rgstg.location
  resource_group_name = azurerm_resource_group.rgstg.name

  route {
    name                   = "default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "172.28.136.71"
  }
}

resource "azurerm_subnet_route_table_association" "rt_wfe_assoc" {
  subnet_id      = azurerm_subnet.wfe.id
  route_table_id = azurerm_route_table.rt_wfe.id
}

resource "azurerm_route_table" "rt_pe" {
  name                = "rt-moph-dhp-stg-pe-qc-001"
  location            = azurerm_resource_group.rgstg.location
  resource_group_name = azurerm_resource_group.rgstg.name

  route {
    name                   = "default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "172.28.136.71"
  }
}

resource "azurerm_subnet_route_table_association" "rt_pe_assoc" {
  subnet_id      = azurerm_subnet.pe.id
  route_table_id = azurerm_route_table.rt_pe.id
}
##################################################
# Network Security Groups
##################################################

resource "azurerm_network_security_group" "nsgapp" {
  name                = "nsg-moph-dhp-stg-app-qc-001"
  resource_group_name = azurerm_resource_group.rgstg.name
  location            = azurerm_resource_group.rgstg.location
}

resource "azurerm_network_security_group" "nsgwfe" {
  name                = "nsg-moph-dhp-stg-wfe-qc-001"
  resource_group_name = azurerm_resource_group.rgstg.name
  location            = azurerm_resource_group.rgstg.location
}

resource "azurerm_network_security_group" "nsgpe" {
  name                = "nsg-moph-dhp-stg-pe-qc-001"
  resource_group_name = azurerm_resource_group.rgstg.name
  location            = azurerm_resource_group.rgstg.location
}

resource "azurerm_subnet_network_security_group_association" "nsg_app_association" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.nsgapp.id
}

resource "azurerm_subnet_network_security_group_association" "nsg_wfe_association" {
  subnet_id                 = azurerm_subnet.wfe.id
  network_security_group_id = azurerm_network_security_group.nsgwfe.id
}

resource "azurerm_subnet_network_security_group_association" "nsg_pe_association" {
  subnet_id                 = azurerm_subnet.pe.id
  network_security_group_id = azurerm_network_security_group.nsgpe.id
}

##################################################
# Hub VNet and Peerings
##################################################

data "azurerm_virtual_network" "hub" {
  provider            = azurerm.connectivity
  name                = "vnet-connectivity-qc-001"
  resource_group_name = "rg-network-connectivity-qc-001"
}

resource "azurerm_virtual_network_peering" "dhp_to_hub" {
  name                         = "peer-vnet-moph-dhp-stg-qc-001-to-vnet-connectivity-qc-001"
  resource_group_name          = azurerm_resource_group.rgstg.name
  virtual_network_name         = azurerm_virtual_network.vnetstg.name
  remote_virtual_network_id    = data.azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = true
  allow_gateway_transit        = false
}

resource "azurerm_virtual_network_peering" "hub_to_dhp" {
  provider                     = azurerm.connectivity
  name                         = "peer-vnet-connectivity-qc-001-to-vnet-moph-dhp-stg-qc-001"
  resource_group_name          = "rg-network-connectivity-qc-001"
  virtual_network_name         = data.azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.vnetstg.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}

##################################################
# User Assigned Managed Identity
##################################################

resource "azurerm_user_assigned_identity" "uami" {
  name                = "id-moph-dhp-stg-cmk-qc-001"
  resource_group_name = azurerm_resource_group.rgstg.name
  location            = azurerm_resource_group.rgstg.location
}

##################################################
# Key Vault, Private Endpoint and Private DNS
##################################################

resource "azurerm_key_vault" "kv" {
  name                = "kv-dhp-stg-cmk-qc-001"
  resource_group_name = azurerm_resource_group.rgstg.name
  location            = azurerm_resource_group.rgstg.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "premium"

  rbac_authorization_enabled   = true
  purge_protection_enabled     = true
  soft_delete_retention_days   = 90
  public_network_access_enabled = true
}

data "azurerm_private_dns_zone" "dnskv" {
  provider            = azurerm.dns
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = "rg-dns-prod-qc-001"
}

resource "azurerm_private_endpoint" "pekv" {
  name                = "pe-kv-dhp-stg-cmk-qc-001"
  location            = azurerm_resource_group.rgstg.location
  resource_group_name = azurerm_resource_group.rgstg.name
  subnet_id           = azurerm_subnet.pe.id

  private_service_connection {
    name                           = "psc-kv-dhp-stg-cmk-qc-001"
    private_connection_resource_id = azurerm_key_vault.kv.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "default"
    private_dns_zone_ids = [
      data.azurerm_private_dns_zone.dnskv.id
    ]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "dhp" {
  provider              = azurerm.dns
  name                  = "dnslink-vnet-moph-dhp-stg-qc-001"
  resource_group_name   = "rg-dns-prod-qc-001"
  private_dns_zone_name = data.azurerm_private_dns_zone.dnskv.name
  virtual_network_id    = azurerm_virtual_network.vnetstg.id
  registration_enabled  = false
}

##################################################
# Key Vault RBAC and Customer Managed Key
##################################################

resource "azurerm_role_assignment" "kv_admin" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_key" "cmk" {
  name         = "cmkdhpdesstg1"
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = "RSA"
  key_size     = 3072

  key_opts = [
    "encrypt",
    "decrypt",
    "sign",
    "verify",
    "wrapKey",
    "unwrapKey"
  ]

  depends_on = [
    azurerm_role_assignment.kv_admin
  ]
}

resource "azurerm_role_assignment" "crypto_user" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_user_assigned_identity.uami.principal_id

  skip_service_principal_aad_check = true
}

##################################################
# Disk Encryption Set
##################################################

resource "azurerm_disk_encryption_set" "des" {
  name                = "descmkmophdhpstg"
  location            = azurerm_resource_group.rgstg.location
  resource_group_name = azurerm_resource_group.rgstg.name
  key_vault_key_id    = azurerm_key_vault_key.cmk.versionless_id

  encryption_type           = "EncryptionAtRestWithCustomerKey"
  auto_key_rotation_enabled = true

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.uami.id
    ]
  }

  depends_on = [
    azurerm_role_assignment.crypto_user
  ]
}
