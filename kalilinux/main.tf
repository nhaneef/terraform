terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "33a5650c-d74b-4b7a-bdb8-724df9a65407"
}

##############################################################################
# VARIABLES
##############################################################################

variable "admin_password" {
  description = "Local administrator password"
  type        = string
  sensitive   = true
}

##############################################################################
# EXISTING RESOURCES
##############################################################################

data "azurerm_resource_group" "rg" {
  name = "rg-cybersecurity-section-soc-prd-001"
}

data "azurerm_virtual_network" "vnet" {
  name                = "vnet-moph-mgmt-qc-001"
  resource_group_name = "rg-vnet-moph-mgmt-qc-001"
}

data "azurerm_subnet" "subnet" {
  name                 = "snet-moph-mgmt-qc-001"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = "rg-vnet-moph-mgmt-qc-001"
}

data "azurerm_disk_encryption_set" "des" {
name = "descmkmophmgmt"
resource_group_name = "rg-moph-cmk-mgmt-qc-001"
}

##############################################################################
# NETWORK INTERFACE
##############################################################################

resource "azurerm_network_interface" "nic" {
  name                = "nic-mophazkalilinux01"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

##############################################################################
# KALI LINUX VM
##############################################################################

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "mophazkalilinux01"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  size           = "Standard_D2s_v5"
  admin_username = "mophazadmin"
  admin_password = var.admin_password

  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  os_disk {
    name                   = "osdisk-mophazkalilinux01"
    caching                = "ReadWrite"
    storage_account_type   = "Premium_LRS"
    disk_size_gb           = 128
    disk_encryption_set_id = data.azurerm_disk_encryption_set.des.id
  }

plan {
  publisher = "kali-linux"
  product   = "kali"
  name      = "kali-2026-2"
}
source_image_reference {
  publisher = "kali-linux"
  offer     = "kali"
  sku       = "kali-2026-2"
  version   = "2026.2.0"
}

  secure_boot_enabled = false
  vtpm_enabled        = false
}