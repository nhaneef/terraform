# terraform {
#   required_version = ">=1.5.0"

#   required_providers {
#     azurerm = {
#       source  = "hashicorp/azurerm"
#       version = "~>4.0"
#     }
#   }
# }

# provider "azurerm" {
#   features {}

#   subscription_id = "31c5e920-b31c-45e2-983a-fc020c73e790"
# }

# data "azurerm_client_config" "current" {}

# locals {
#   windows_license_type = "Windows_Server"
# }

# variable "admin_password" {
#   description = "Local administrator password"
#   type        = string
#   sensitive   = true
# }
# ########################################
# # New Resource 
# ########################################
# resource "azurerm_resource_group" "rgstg" {
#   name     = "rg-moph-dhp-stg-qc-001"
#   location = "Qatar Central"
# }

# resource "azurerm_virtual_network" "vnetstg" {
#   name                = "vnet-moph-dhp-stg-qc-001"
#   resource_group_name = azurerm_resource_group.rgstg.name
#   location            = azurerm_resource_group.rgstg.location
#   address_space       = ["172.30.236.64/26"]
# }
# resource "azurerm_subnet" "app" {
#   name                              = "snet-moph-dhp-stg-app-qc-001"
#   virtual_network_name              = azurerm_virtual_network.vnetstg.name
#   resource_group_name               = azurerm_resource_group.rgstg.name
#   address_prefixes                  = ["172.30.236.64/28"]
#   private_endpoint_network_policies = "Disabled"
# }

# resource "azurerm_subnet" "wfe" {
#   name                              = "snet-moph-dhp-stg-wfe-qc-001"
#   virtual_network_name              = azurerm_virtual_network.vnetstg.name
#   resource_group_name               = azurerm_resource_group.rgstg.name
#   address_prefixes                  = ["172.30.236.80/28"]
#   private_endpoint_network_policies = "Disabled"
# }

# resource "azurerm_subnet" "pe" {
#   name                              = "snet-moph-dhp-stg-pe-qc-001"
#   virtual_network_name              = azurerm_virtual_network.vnetstg.name
#   resource_group_name               = azurerm_resource_group.rgstg.name
#   address_prefixes                  = ["172.30.236.96/28"]
#   private_endpoint_network_policies = "Disabled"
# }

# resource "azurerm_network_security_group" "nsgvms" {
#   name                = "nsg-moph-dhp-stg-vm-qc-001"
#   resource_group_name = azurerm_resource_group.rgstg.name
#   location            = azurerm_resource_group.rgstg.location
# }
# resource "azurerm_network_security_group" "nsgpe" {
#   name                = "nsg-moph-dhp-stg-pe-qc-001"
#   resource_group_name = azurerm_resource_group.rgstg.name
#   location            = azurerm_resource_group.rgstg.location
# }

# resource "azurerm_subnet_network_security_group_association" "nsgvmsasso" {

#   subnet_id                 = azurerm_subnet.vms.id
#   network_security_group_id = azurerm_network_security_group.nsgvms.id
# }

# resource "azurerm_subnet_network_security_group_association" "nsgpeasso" {

#   subnet_id                 = azurerm_subnet.pe.id
#   network_security_group_id = azurerm_network_security_group.nsgpe.id
# }

# #####################################################################
# # Vnet Peering t
# # Connectitvity subscription
# ###########
# provider "azurerm" {
#   alias = "connectivity"
#   features {}
#   subscription_id = "845b4977-4f63-4971-a926-dd691fd2e258"
# }
# #######################################################3333
# # DHP to Hub peering
# data "azurerm_virtual_network" "hub" {
#   provider            = azurerm.connectivity
#   name                = "vnet-connectivity-qc-001"
#   resource_group_name = "rg-network-connectivity-qc-001"
# }

# resource "azurerm_virtual_network_peering" "dhp_to_hub" {
#   name                         = "peer-vnet-moph-dhp-stg-qc-001-to-vnet-connectivity-qc-001"
#   resource_group_name          = azurerm_resource_group.rgstg.name
#   virtual_network_name         = azurerm_virtual_network.vnetstg.name
#   remote_virtual_network_id    = data.azurerm_virtual_network.hub.id
#   allow_virtual_network_access = true
#   allow_forwarded_traffic      = true
#   use_remote_gateways          = true
#   allow_gateway_transit        = false
# }

# ######################################333
# # Hub to DHP 

# resource "azurerm_virtual_network_peering" "hub_to_dhp" {

#   provider                     = azurerm.connectivity
#   name                         = "peer-vnet-connectivity-qc-001-to-vnet-moph-dhp-stg-qc-001"
#   resource_group_name          = "rg-network-connectivity-qc-001"
#   virtual_network_name         = "vnet-connectivity-qc-001"
#   remote_virtual_network_id    = azurerm_virtual_network.vnetstg.id
#   allow_virtual_network_access = true
#   allow_forwarded_traffic      = true
#   allow_gateway_transit        = true
#   use_remote_gateways          = false
# }


# ###############################################################
# # For CMK
# ##############################################################
# # User managed Identity

# resource "azurerm_user_assigned_identity" "uami" {
#   name                = "id-moph-dhp-stg-cmk-qc-001"
#   resource_group_name = azurerm_resource_group.rgstg.name
#   location            = azurerm_resource_group.rgstg.location
# }
# #############################################################
# # Key Vault
# ############################################################
# resource "azurerm_key_vault" "kv" {
#   name                = "kv-dhp-stg-cmk-qc-001"
#   resource_group_name = azurerm_resource_group.rgstg.name
#   location            = azurerm_resource_group.rgstg.location

#   tenant_id = data.azurerm_client_config.current.tenant_id

#   sku_name = "premium"

#   rbac_authorization_enabled = true
#   purge_protection_enabled   = true
#   soft_delete_retention_days = 90

#   public_network_access_enabled = true
# }

# #####################################################################
# # Private Endpoint
# ######################################################################

# resource "azurerm_private_endpoint" "pekv" {
#   name                = "pe-kv-dhp-stg-cmk-qc-001"
#   location            = azurerm_resource_group.rgstg.location
#   resource_group_name = azurerm_resource_group.rgstg.name
#   subnet_id           = azurerm_subnet.pe.id

#   private_service_connection {
#     name                           = "psc-kv-dhp-stg-cmk-qc-001"
#     private_connection_resource_id = azurerm_key_vault.kv.id
#     subresource_names              = ["vault"]
#     is_manual_connection           = false
#   }
#   private_dns_zone_group {
#     name = "default"

#     private_dns_zone_ids = [
#       data.azurerm_private_dns_zone.dnskv.id
#     ]
#   }
# }
# ###################################################################
# # Private DNS Zone -Vnet linking

# provider "azurerm" {
#   alias = "dns"
#   features {}
#   subscription_id = "845b4977-4f63-4971-a926-dd691fd2e258"
# }

# data "azurerm_private_dns_zone" "dnskv" {
#   provider            = azurerm.dns
#   name                = "privatelink.vaultcore.azure.net"
#   resource_group_name = "rg-dns-prod-qc-001"
# }


# resource "azurerm_private_dns_zone_virtual_network_link" "dhp" {
#   provider = azurerm.dns

#   name                  = "dnslink-vnet-moph-dhp-stg-qc-001"
#   resource_group_name   = "rg-dns-prod-qc-001"
#   private_dns_zone_name = data.azurerm_private_dns_zone.dnskv.name

#   virtual_network_id = azurerm_virtual_network.vnetstg.id

#   registration_enabled = false
# }
# ##########################################################################
# # Role Assignment for UAMI 

# resource "azurerm_role_assignment" "kv_admin" {
#   scope                = azurerm_key_vault.kv.id
#   role_definition_name = "Key Vault Administrator"
#   principal_id         = data.azurerm_client_config.current.object_id
# }


# ##################################################
# # Customer Managed Key
# ##################################################

# resource "azurerm_key_vault_key" "cmk" {
#   name         = "cmkdhpdesstg1"
#   key_vault_id = azurerm_key_vault.kv.id

#   key_type = "RSA"
#   key_size = 3072

#   key_opts = [
#     "encrypt",
#     "decrypt",
#     "sign",
#     "verify",
#     "wrapKey",
#     "unwrapKey"
#   ]

#   depends_on = [
#     azurerm_role_assignment.kv_admin
#   ]
# }
# ############################################################

# # Grant Managed Identity Access To CMK
# ##################################################

# resource "azurerm_role_assignment" "crypto_user" {
#   scope                = azurerm_key_vault.kv.id
#   role_definition_name = "Key Vault Crypto Service Encryption User"

#   principal_id = azurerm_user_assigned_identity.uami.principal_id

#   skip_service_principal_aad_check = true
# }
# ##################################################################
# ##################################################
# # Disk Encryption Set
# ##################################################

# resource "azurerm_disk_encryption_set" "des" {
#   name                = "descmkmophdhpstg"
#   location            = azurerm_resource_group.rgstg.location
#   resource_group_name = azurerm_resource_group.rgstg.name

#   key_vault_key_id = azurerm_key_vault_key.cmk.versionless_id

#   encryption_type           = "EncryptionAtRestWithCustomerKey"
#   auto_key_rotation_enabled = true

#   identity {
#     type = "UserAssigned"

#     identity_ids = [
#       azurerm_user_assigned_identity.uami.id
#     ]
#   }

#   depends_on = [
#     azurerm_role_assignment.crypto_user
#   ]
# }



# ###################################################
# # stgapp01 NIC
# ##################################################

# resource "azurerm_network_interface" "stgapp01_nic" {
#   name                = "mophazsdhp01-nic"
#   location            = azurerm_resource_group.rgstg.location
#   resource_group_name = azurerm_resource_group.rgstg.name

#   ip_configuration {
#     name                          = "ipconfig1"
#     subnet_id                     = azurerm_subnet.vms.id
#     private_ip_address_allocation = "Dynamic"
#   }
# }

# ##################################################
# # stgapp02 NIC
# ##################################################

# resource "azurerm_network_interface" "stgapp02_nic" {
#   name                = "mophazsdhp02-nic"
#   location            = azurerm_resource_group.rgstg.location
#   resource_group_name = azurerm_resource_group.rgstg.name

#   ip_configuration {
#     name                          = "ipconfig1"
#     subnet_id                     = azurerm_subnet.vms.id
#     private_ip_address_allocation = "Dynamic"
#   }
# }


# ##################################################
# # stgapp01 VM
# ##################################################

# resource "azurerm_windows_virtual_machine" "stgapp01" {

#   name          = "mophazsdhp01"
#   computer_name = "mophazsdhp01"

#   location            = azurerm_resource_group.rgstg.location
#   resource_group_name = azurerm_resource_group.rgstg.name

#   # zone                = "1"

#   size = "Standard_D4s_v5"

#   admin_username = "mophazadmin"
#   admin_password = var.admin_password

#   license_type = local.windows_license_type

#   network_interface_ids = [
#     azurerm_network_interface.stgapp01_nic.id
#   ]

#   encryption_at_host_enabled = true
#   secure_boot_enabled        = true
#   vtpm_enabled               = true

#   identity {
#     type = "SystemAssigned"
#   }

#   os_disk {
#     name                   = "mophazsdhp01-osdisk"
#     caching                = "ReadWrite"
#     storage_account_type   = "StandardSSD_LRS"
#     disk_size_gb           = 200
#     disk_encryption_set_id = azurerm_disk_encryption_set.des.id
#   }

#   source_image_reference {
#     publisher = "MicrosoftWindowsServer"
#     offer     = "WindowsServer"
#     sku       = "2025-datacenter-g2"
#     version   = "latest"
#   }
# }

# ##################################################
# # stgapp02 VM
# ##################################################

# resource "azurerm_windows_virtual_machine" "stgapp02" {

#   name          = "mophazsdhp02"
#   computer_name = "mophazsdhp02"

#   location            = azurerm_resource_group.rgstg.location
#   resource_group_name = azurerm_resource_group.rgstg.name

#   # zone                = "2"

#   size = "Standard_D4s_v5"

#   admin_username = "mophazadmin"
#   admin_password = var.admin_password

#   license_type = local.windows_license_type

#   network_interface_ids = [
#     azurerm_network_interface.stgapp02_nic.id
#   ]

#   encryption_at_host_enabled = true
#   secure_boot_enabled        = true
#   vtpm_enabled               = true

#   identity {
#     type = "SystemAssigned"
#   }

#   os_disk {
#     name                   = "mophazsdhp02-osdisk"
#     caching                = "ReadWrite"
#     storage_account_type   = "StandardSSD_LRS"
#     disk_size_gb           = 200
#     disk_encryption_set_id = azurerm_disk_encryption_set.des.id
#   }

#   source_image_reference {
#     publisher = "MicrosoftWindowsServer"
#     offer     = "WindowsServer"
#     sku       = "2025-datacenter-g2"
#     version   = "latest"
#   }
# }

# ##################################################
# # stgapp01 DATA DISK
# ##################################################

# resource "azurerm_managed_disk" "stgapp01_data" {
#   name                = "mophazsdhp01-data"
#   location            = azurerm_resource_group.rgstg.location
#   resource_group_name = azurerm_resource_group.rgstg.name

#   storage_account_type = "Standard_LRS"
#   create_option        = "Empty"
#   disk_size_gb         = 500

#   disk_encryption_set_id = azurerm_disk_encryption_set.des.id
# }

# resource "azurerm_virtual_machine_data_disk_attachment" "stgapp01_data" {
#   managed_disk_id    = azurerm_managed_disk.stgapp01_data.id
#   virtual_machine_id = azurerm_windows_virtual_machine.stgapp01.id

#   lun     = 0
#   caching = "ReadWrite"
# }


# resource "azurerm_managed_disk" "stgapp02_data" {
#   name                = "mophazsdhp02-data"
#   location            = azurerm_resource_group.rgstg.location
#   resource_group_name = azurerm_resource_group.rgstg.name

#   storage_account_type = "Standard_LRS"
#   create_option        = "Empty"
#   disk_size_gb         = 500

#   disk_encryption_set_id = azurerm_disk_encryption_set.des.id
# }

# resource "azurerm_virtual_machine_data_disk_attachment" "stgapp02_data" {
#   managed_disk_id    = azurerm_managed_disk.stgapp02_data.id
#   virtual_machine_id = azurerm_windows_virtual_machine.stgapp02.id

#   lun     = 0
#   caching = "ReadWrite"
# }

# resource "azurerm_managed_disk" "stgapp01_log" {
#   name                = "mophazsdhp01-log"
#   location            = azurerm_resource_group.rgstg.location
#   resource_group_name = azurerm_resource_group.rgstg.name

#   storage_account_type = "Standard_LRS"
#   create_option        = "Empty"
#   disk_size_gb         = 80

#   disk_encryption_set_id = azurerm_disk_encryption_set.des.id
# }

# resource "azurerm_managed_disk" "stgapp02_log" {
#   name                = "mophazsdhp02-log"
#   location            = azurerm_resource_group.rgstg.location
#   resource_group_name = azurerm_resource_group.rgstg.name

#   storage_account_type = "Standard_LRS"
#   create_option        = "Empty"
#   disk_size_gb         = 80

#   disk_encryption_set_id = azurerm_disk_encryption_set.des.id
# }

# resource "azurerm_virtual_machine_data_disk_attachment" "stgapp01_log" {
#   managed_disk_id    = azurerm_managed_disk.stgapp01_log.id
#   virtual_machine_id = azurerm_windows_virtual_machine.stgapp01.id

#   lun     = 1
#   caching = "None"
# }

# resource "azurerm_virtual_machine_data_disk_attachment" "stgapp02_log" {
#   managed_disk_id    = azurerm_managed_disk.stgapp02_log.id
#   virtual_machine_id = azurerm_windows_virtual_machine.stgapp02.id

#   lun     = 1
#   caching = "None"
# }
