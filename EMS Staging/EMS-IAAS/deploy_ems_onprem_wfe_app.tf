terraform {
  required_version = ">=1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "80936d31-4fa0-47d4-9850-4c2814100866"
}

data "azurerm_client_config" "current" {}

locals {
windows_license_type = "Windows_Server"
}
########################################
# EXISTING RESOURCES
########################################

data "azurerm_subnet" "fe" {
  name                 = "snet-ems-onprem-fe-stg-qc-001"
  virtual_network_name = "vnet-ems-onprem-network-stg-qc-001"
  resource_group_name  = "rg-ems-onprem-network-stg-qc-001"
}

data "azurerm_subnet" "be" {
  name                 = "snet-ems-onprem-be-stg-qc-001"
  virtual_network_name = "vnet-ems-onprem-network-stg-qc-001"
  resource_group_name  = "rg-ems-onprem-network-stg-qc-001"
}

data "azurerm_subnet" "db" {
  name                 = "snet-ems-onprem-db-stg-qc-001"
  virtual_network_name = "vnet-ems-onprem-network-stg-qc-001"
  resource_group_name  = "rg-ems-onprem-network-stg-qc-001"
}
data "azurerm_subnet" "dbcls" {
  name                 = "snet-ems-onprem-db-cls-stg-qc-001"
  virtual_network_name = "vnet-ems-onprem-network-stg-qc-001"
  resource_group_name  = "rg-ems-onprem-network-stg-qc-001"
}



data "azurerm_disk_encryption_set" "des" {
  name                = "descmkemonpsstg"
  resource_group_name = "RG-EMS-ONPREM-PAAS-STG-QC-001"
}
########################################
# WFE01 NIC
########################################

resource "azurerm_network_interface" "wfe01_nic" {
  name                = "MOPHAZEMSSWFE01-nic"
  location            = "qatarcentral"
  resource_group_name = "rg-ems-onprem-iaas-stg-qc-001"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = data.azurerm_subnet.fe.id
    private_ip_address_allocation = "Dynamic"
  }
}

########################################
# WFE01 VM
########################################

resource "azurerm_windows_virtual_machine" "wfe01" {

  name                = "MOPHAZEMSSWFE01"
  computer_name       = "MOPHAZEMSSWFE01"
  location            = "qatarcentral"
  resource_group_name = "rg-ems-onprem-iaas-stg-qc-001"
  zone = "1"
  size           = "Standard_D8s_v5"
  admin_username = "mophazadmin"
  admin_password = var.admin_password
  license_type = "Windows_Server"
  network_interface_ids = [
    azurerm_network_interface.wfe01_nic.id
  ]

  encryption_at_host_enabled = true
  secure_boot_enabled        = true
  vtpm_enabled               = true

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                   = "MOPHAZEMSSWFE01-osdisk"
    caching                = "ReadWrite"
    storage_account_type   = "Premium_LRS"
    disk_size_gb           = 127
    disk_encryption_set_id = data.azurerm_disk_encryption_set.des.id
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-datacenter-g2"
    version   = "latest"
  }
}

########################################
# WFE02 NIC
########################################

resource "azurerm_network_interface" "wfe02_nic" {
  name                = "MOPHAZEMSSWFE02-nic"
  location            = "qatarcentral"
  resource_group_name = "rg-ems-onprem-iaas-stg-qc-001"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = data.azurerm_subnet.fe.id
    private_ip_address_allocation = "Dynamic"
  }
}

########################################
# WFE02 VM
########################################

resource "azurerm_windows_virtual_machine" "wfe02" {

  name                = "MOPHAZEMSSWFE02"
  computer_name       = "MOPHAZEMSSWFE02"
  location            = "qatarcentral"
  resource_group_name = "rg-ems-onprem-iaas-stg-qc-001"
  zone = "2"
  size           = "Standard_D8s_v5"
  admin_username = "mophazadmin"
  admin_password = var.admin_password
  license_type = "Windows_Server"
  network_interface_ids = [
    azurerm_network_interface.wfe02_nic.id
  ]

  encryption_at_host_enabled = true
  secure_boot_enabled        = true
  vtpm_enabled               = true

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                   = "MOPHAZEMSSWFE02-osdisk"
    caching                = "ReadWrite"
    storage_account_type   = "Premium_LRS"
    disk_size_gb           = 127
    disk_encryption_set_id = data.azurerm_disk_encryption_set.des.id
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-datacenter-g2"
    version   = "latest"
  }
}

########################################
# APP01 NIC
###############################
resource "azurerm_network_interface" "app01_nic" {
  name                = "MOPHAZEMSSAPP01-nic"
  location            = "qatarcentral"
  resource_group_name = "rg-ems-onprem-iaas-stg-qc-001"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = data.azurerm_subnet.be.id
    private_ip_address_allocation = "Dynamic"
  }
}

########################################
# APP01 VM
########################################

resource "azurerm_windows_virtual_machine" "app01" {

  name                = "MOPHAZEMSSAPP01"
  computer_name       = "MOPHAZEMSSAPP01"
  location            = "qatarcentral"
  resource_group_name = "rg-ems-onprem-iaas-stg-qc-001"
  zone = "1"
  size           = "Standard_D8s_v5"
  admin_username = "mophazadmin"
  admin_password = var.admin_password
  license_type = "Windows_Server"

  network_interface_ids = [
    azurerm_network_interface.app01_nic.id
  ]

  encryption_at_host_enabled = true
  secure_boot_enabled        = true
  vtpm_enabled               = true
  
  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                   = "MOPHAZEMSSAPP01-osdisk"
    caching                = "ReadWrite"
    storage_account_type   = "Premium_LRS"
    disk_size_gb           = 127
    disk_encryption_set_id = data.azurerm_disk_encryption_set.des.id
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-datacenter-g2"
    version   = "latest"
  }
}


########################################
# APP02 NIC
###############################
resource "azurerm_network_interface" "app02_nic" {
  name                = "MOPHAZEMSSAPP02-nic"
  location            = "qatarcentral"
  resource_group_name = "rg-ems-onprem-iaas-stg-qc-001"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = data.azurerm_subnet.be.id
    private_ip_address_allocation = "Dynamic"
  }
}

########################################
# APP02 VM
########################################

resource "azurerm_windows_virtual_machine" "app02" {

  name                = "MOPHAZEMSSAPP02"
  computer_name       = "MOPHAZEMSSAPP02"
  location            = "qatarcentral"
  resource_group_name = "rg-ems-onprem-iaas-stg-qc-001"
  zone = "2"
  size           = "Standard_D8s_v5"
  admin_username = "mophazadmin"
  admin_password = var.admin_password
  license_type = "Windows_Server"
  network_interface_ids = [
    azurerm_network_interface.app02_nic.id
  ]

  encryption_at_host_enabled = true
  secure_boot_enabled        = true
  vtpm_enabled               = true

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                   = "MOPHAZEMSSAPP02-osdisk"
    caching                = "ReadWrite"
    storage_account_type   = "Premium_LRS"
    disk_size_gb           = 127
    disk_encryption_set_id = data.azurerm_disk_encryption_set.des.id
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-datacenter-g2"
    version   = "latest"
  }
}



########################################
# DB01 NIC
###############################
resource "azurerm_network_interface" "db01_nic" {
  name                = "MOPHAZEMSSDB01-nic"
  location            = "qatarcentral"
  resource_group_name = "rg-ems-onprem-iaas-stg-qc-001"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = data.azurerm_subnet.db.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "db01_cluster_nic" {
  name                = "MOPHAZEMSSDB01-cluster-nic"
  location            = "qatarcentral"
  resource_group_name = "rg-ems-onprem-iaas-stg-qc-001"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = data.azurerm_subnet.dbcls.id
    private_ip_address_allocation = "Dynamic"
  }
}

########################################
# DB01 VM
########################################

resource "azurerm_windows_virtual_machine" "db01" {

  name                = "MOPHAZEMSSDB01"
  computer_name       = "MOPHAZEMSSDB01"
  location            = "qatarcentral"
  resource_group_name = "rg-ems-onprem-iaas-stg-qc-001"
  zone = "1"
  size           = "Standard_F8s_v2"
  admin_username = "mophazadmin"
  admin_password = var.admin_password
  license_type = "Windows_Server"
  network_interface_ids = [
    azurerm_network_interface.db01_nic.id,
    azurerm_network_interface.db01_cluster_nic.id
  ]

  encryption_at_host_enabled = true
  secure_boot_enabled        = true
  vtpm_enabled               = true

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                   = "MOPHAZEMSSDB01-osdisk"
    caching                = "ReadWrite"
    storage_account_type   = "Premium_LRS"
    disk_size_gb           = 127
    disk_encryption_set_id = data.azurerm_disk_encryption_set.des.id
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-datacenter-g2"
    version   = "latest"
  }
}


########################################
# DB02 NIC
###############################
resource "azurerm_network_interface" "db02_nic" {
  name                = "MOPHAZEMSSDB02-nic"
  location            = "qatarcentral"
  resource_group_name = "rg-ems-onprem-iaas-stg-qc-001"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = data.azurerm_subnet.db.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface" "db02_cluster_nic" {
  name                = "MOPHAZEMSSDB02-cluster-nic"
  location            = "qatarcentral"
  resource_group_name = "rg-ems-onprem-iaas-stg-qc-001"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = data.azurerm_subnet.dbcls.id
    private_ip_address_allocation = "Dynamic"
  }
}
########################################
# DB02 VM
########################################

resource "azurerm_windows_virtual_machine" "db02" {

  name                = "MOPHAZEMSSDB02"
  computer_name       = "MOPHAZEMSSDB02"
  location            = "qatarcentral"
  resource_group_name = "rg-ems-onprem-iaas-stg-qc-001"
  zone = "2"
  size           = "Standard_F8s_v2"
  admin_username = "mophazadmin"
  admin_password = var.admin_password
  license_type = "Windows_Server"
  network_interface_ids = [
    azurerm_network_interface.db02_nic.id,
    azurerm_network_interface.db02_cluster_nic.id
  ]

  encryption_at_host_enabled = true
  secure_boot_enabled        = true
  vtpm_enabled               = true

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                   = "MOPHAZEMSSDB02-osdisk"
    caching                = "ReadWrite"
    storage_account_type   = "Premium_LRS"
    disk_size_gb           = 127
    disk_encryption_set_id = data.azurerm_disk_encryption_set.des.id
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-datacenter-g2"
    version   = "latest"
  }
}


########################################
# STS01 NIC
###############################
resource "azurerm_network_interface" "sts01_nic" {
  name                = "MOPHAZEMSSSTS01-nic"
  location            = "qatarcentral"
  resource_group_name = "rg-ems-onprem-iaas-stg-qc-001"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = data.azurerm_subnet.be.id
    private_ip_address_allocation = "Dynamic"
  }
}

########################################
# STS01 VM
########################################

resource "azurerm_windows_virtual_machine" "sts01" {

  name                = "MOPHAZEMSSSTS01"
  computer_name       = "MOPHAZEMSSSTS01"
  location            = "qatarcentral"
  resource_group_name = "rg-ems-onprem-iaas-stg-qc-001"
  zone = "1"
  size           = "Standard_F8s_v2"
  admin_username = "mophazadmin"
  admin_password = var.admin_password
  license_type = "Windows_Server"
  network_interface_ids = [
    azurerm_network_interface.sts01_nic.id
  ]

  encryption_at_host_enabled = true
  secure_boot_enabled        = true
  vtpm_enabled               = true

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                   = "MOPHAZEMSSSTS01-osdisk"
    caching                = "ReadWrite"
    storage_account_type   = "Premium_LRS"
    disk_size_gb           = 127
    disk_encryption_set_id = data.azurerm_disk_encryption_set.des.id
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-datacenter-g2"
    version   = "latest"
  }
}


########################################
# STS02 NIC
###############################
resource "azurerm_network_interface" "sts02_nic" {
  name                = "MOPHAZEMSSSTS02-nic"
  location            = "qatarcentral"
  resource_group_name = "rg-ems-onprem-iaas-stg-qc-001"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = data.azurerm_subnet.be.id
    private_ip_address_allocation = "Dynamic"
  }
}

########################################
# STS02 VM
########################################

resource "azurerm_windows_virtual_machine" "sts02" {

  name                = "MOPHAZEMSSSTS02"
  computer_name       = "MOPHAZEMSSSTS02"
  location            = "qatarcentral"
  resource_group_name = "rg-ems-onprem-iaas-stg-qc-001"
  zone = "2"
  size           = "Standard_F8s_v2"
  admin_username = "mophazadmin"
  admin_password = var.admin_password
  license_type = "Windows_Server"
  network_interface_ids = [
    azurerm_network_interface.sts02_nic.id
  ]

  encryption_at_host_enabled = true
  secure_boot_enabled        = true
  vtpm_enabled               = true

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                   = "MOPHAZEMSSSTS02-osdisk"
    caching                = "ReadWrite"
    storage_account_type   = "Premium_LRS"
    disk_size_gb           = 127
    disk_encryption_set_id = data.azurerm_disk_encryption_set.des.id
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-datacenter-g2"
    version   = "latest"
  }
}