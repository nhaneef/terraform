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

  subscription_id = "31c5e920-b31c-45e2-983a-fc020c73e790"
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
########################################
# New Resource 
########################################
resource "azurerm_resource_group" "rgdev" {
  name     = "rg-moph-dhp-dev-qc-001"
  location = "Qatar Central"
}

resource "azurerm_virtual_network" "vnetdev" {
  name                = "vnet-moph-dhp-dev-qc-001"
  resource_group_name = azurerm_resource_group.rgdev.name
  location            = azurerm_resource_group.rgdev.location
  address_space       = ["172.30.240.64/27","172.28.196.248/29"]
}
resource "azurerm_subnet" "vms" {
  name                              = "snet-moph-dhp-dev-vm-qc-001"
  virtual_network_name              = azurerm_virtual_network.vnetdev.name
  resource_group_name               = azurerm_resource_group.rgdev.name
  address_prefixes                  = ["172.30.240.64/28"]
  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_subnet" "pe" {
  name                              = "snet-moph-dhp-dev-pe-qc-001"
  virtual_network_name              = azurerm_virtual_network.vnetdev.name
  resource_group_name               = azurerm_resource_group.rgdev.name
  address_prefixes                  = ["172.30.240.80/28"]
  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_subnet" "dbcls" {
  name                              = "snet-moph-dhp-dev-dbcls-qc-001"
  virtual_network_name              = azurerm_virtual_network.vnetdev.name
  resource_group_name               = azurerm_resource_group.rgdev.name
  address_prefixes                  = ["172.28.196.248/29"]
  private_endpoint_network_policies = "Disabled"
}
resource "azurerm_network_security_group" "nsgvms" {
  name                = "nsg-moph-dhp-dev-vm-qc-001"
  resource_group_name = azurerm_resource_group.rgdev.name
  location            = azurerm_resource_group.rgdev.location
}
resource "azurerm_network_security_group" "nsgpe" {
  name                = "nsg-moph-dhp-dev-pe-qc-001"
  resource_group_name = azurerm_resource_group.rgdev.name
  location            = azurerm_resource_group.rgdev.location
}

resource "azurerm_subnet_network_security_group_association" "nsgvmsasso" {

  subnet_id                 = azurerm_subnet.vms.id
  network_security_group_id = azurerm_network_security_group.nsgvms.id
}

resource "azurerm_subnet_network_security_group_association" "nsgpeasso" {

  subnet_id                 = azurerm_subnet.pe.id
  network_security_group_id = azurerm_network_security_group.nsgpe.id
}

# ######################################################################
# ?Route Table

resource "azurerm_route_table" "rt_vm" {
  name                = "rt-moph-dhp-dev-vm-qc-001"
  location            = azurerm_resource_group.rgdev.location
  resource_group_name = azurerm_resource_group.rgdev.name

  route {
    name                   = "default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "172.28.136.71"
  }
}

resource "azurerm_subnet_route_table_association" "rt_vm_assoc" {
  subnet_id      = azurerm_subnet.vms.id
  route_table_id = azurerm_route_table.rt_vm.id
}

resource "azurerm_route_table" "rt_pe" {
  name                = "rt-moph-dhp-dev-pe-qc-001"
  location            = azurerm_resource_group.rgdev.location
  resource_group_name = azurerm_resource_group.rgdev.name

  route {
    name                   = "default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "172.28.136.71"
  }
}

resource "azurerm_route_table" "rt_dbcls" {
  name                = "rt-moph-dhp-dev-dbcls-qc-001"
  location            = azurerm_resource_group.rgdev.location
  resource_group_name = azurerm_resource_group.rgdev.name

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

resource "azurerm_subnet_route_table_association" "rt_dbcls_assoc" {
  subnet_id      = azurerm_subnet.dbcls.id
  route_table_id = azurerm_route_table.rt_dbcls.id
}
#####################################################################
# Vnet Peering t
# Connectitvity subscription
###########
provider "azurerm" {
  alias = "connectivity"
  features {}
  subscription_id = "845b4977-4f63-4971-a926-dd691fd2e258"
}
#######################################################3333
# DHP to Hub peering
data "azurerm_virtual_network" "hub" {
  provider            = azurerm.connectivity
  name                = "vnet-connectivity-qc-001"
  resource_group_name = "rg-network-connectivity-qc-001"
}

resource "azurerm_virtual_network_peering" "dhp_to_hub" {
  name                         = "peer-vnet-moph-dhp-dev-qc-001-to-vnet-connectivity-qc-001"
  resource_group_name          = azurerm_resource_group.rgdev.name
  virtual_network_name         = azurerm_virtual_network.vnetdev.name
  remote_virtual_network_id    = data.azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = true
  allow_gateway_transit        = false
}

######################################333
# Hub to DHP 

resource "azurerm_virtual_network_peering" "hub_to_dhp" {

  provider                     = azurerm.connectivity
  name                         = "peer-vnet-connectivity-qc-001-to-vnet-moph-dhp-dev-qc-001"
  resource_group_name          = "rg-network-connectivity-qc-001"
  virtual_network_name         = "vnet-connectivity-qc-001"
  remote_virtual_network_id    = azurerm_virtual_network.vnetdev.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}


###############################################################
# For CMK
##############################################################
# User managed Identity

resource "azurerm_user_assigned_identity" "uami" {
  name                = "id-moph-dhp-dev-cmk-qc-001"
  resource_group_name = azurerm_resource_group.rgdev.name
  location            = azurerm_resource_group.rgdev.location
}
#############################################################
# Key Vault
############################################################
resource "azurerm_key_vault" "kv" {
  name                = "kv-dhp-dev-cmk-qc-001"
  resource_group_name = azurerm_resource_group.rgdev.name
  location            = azurerm_resource_group.rgdev.location

  tenant_id = data.azurerm_client_config.current.tenant_id

  sku_name = "premium"

  rbac_authorization_enabled = true
  purge_protection_enabled   = true
  soft_delete_retention_days = 90

  public_network_access_enabled = false
}

#####################################################################
# Private Endpoint
######################################################################

resource "azurerm_private_endpoint" "pekv" {
  name                = "pe-kv-dhp-dev-cmk-qc-001"
  location            = azurerm_resource_group.rgdev.location
  resource_group_name = azurerm_resource_group.rgdev.name
  subnet_id           = azurerm_subnet.pe.id

  private_service_connection {
    name                           = "psc-kv-dhp-dev-cmk-qc-001"
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
###################################################################
# Private DNS Zone -Vnet linking

provider "azurerm" {
  alias = "dns"
  features {}
  subscription_id = "845b4977-4f63-4971-a926-dd691fd2e258"
}

data "azurerm_private_dns_zone" "dnskv" {
  provider            = azurerm.dns
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = "rg-dns-prod-qc-001"
}


resource "azurerm_private_dns_zone_virtual_network_link" "dhp" {
  provider = azurerm.dns

  name                  = "dnslink-vnet-moph-dhp-dev-qc-001"
  resource_group_name   = "rg-dns-prod-qc-001"
  private_dns_zone_name = data.azurerm_private_dns_zone.dnskv.name

  virtual_network_id = azurerm_virtual_network.vnetdev.id

  registration_enabled = false
}
##########################################################################
# Role Assignment for UAMI 

resource "azurerm_role_assignment" "kv_admin" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}


##################################################
# Customer Managed Key
##################################################

resource "azurerm_key_vault_key" "cmk" {
  name         = "cmkdhpdesdev1"
  key_vault_id = azurerm_key_vault.kv.id

  key_type = "RSA"
  key_size = 3072

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
############################################################

# Grant Managed Identity Access To CMK
##################################################

resource "azurerm_role_assignment" "crypto_user" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Crypto Service Encryption User"

  principal_id = azurerm_user_assigned_identity.uami.principal_id

  skip_service_principal_aad_check = true
}
##################################################################
##################################################
# Disk Encryption Set
##################################################

resource "azurerm_disk_encryption_set" "des" {
  name                = "descmkmophdhpdev"
  location            = azurerm_resource_group.rgdev.location
  resource_group_name = azurerm_resource_group.rgdev.name

  key_vault_key_id = azurerm_key_vault_key.cmk.versionless_id

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



###################################################
# DEV01 NIC
##################################################

resource "azurerm_network_interface" "dev01_nic" {
  name                = "mophazddhp01-nic"
  location            = azurerm_resource_group.rgdev.location
  resource_group_name = azurerm_resource_group.rgdev.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.vms.id
    private_ip_address_allocation = "Dynamic"
  }
}

##################################################
# DEV02 NIC
##################################################

resource "azurerm_network_interface" "dev02_nic" {
  name                = "mophazddhp02-nic"
  location            = azurerm_resource_group.rgdev.location
  resource_group_name = azurerm_resource_group.rgdev.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.vms.id
    private_ip_address_allocation = "Dynamic"
  }
}

##################################################
# DB01 NIC
##################################################

resource "azurerm_network_interface" "db01_nic" {
  name                = "mophazddhpdb01-nic"
  location            = azurerm_resource_group.rgdev.location
  resource_group_name = azurerm_resource_group.rgdev.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.vms.id
    private_ip_address_allocation = "Dynamic"
  }
}

##################################################
# DB02 NIC
##################################################
resource "azurerm_network_interface" "db02_nic" {
  name                = "mophazddhpdb02-nic"
  location            = azurerm_resource_group.rgdev.location
  resource_group_name = azurerm_resource_group.rgdev.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.vms.id
    private_ip_address_allocation = "Dynamic"
  }
}
##################################################
# DEV01 VM
##################################################

resource "azurerm_windows_virtual_machine" "dev01" {

  name          = "mophazddhp01"
  computer_name = "mophazddhp01"

  location            = azurerm_resource_group.rgdev.location
  resource_group_name = azurerm_resource_group.rgdev.name

  # zone                = "1"

  size = "Standard_D4s_v5"

  admin_username = "mophazadmin"
  admin_password = var.admin_password

  license_type = local.windows_license_type

  network_interface_ids = [
    azurerm_network_interface.dev01_nic.id
  ]

  encryption_at_host_enabled = true
  secure_boot_enabled        = true
  vtpm_enabled               = true

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                   = "mophazddhp01-osdisk"
    caching                = "ReadWrite"
    storage_account_type   = "StandardSSD_LRS"
    disk_size_gb           = 200
    disk_encryption_set_id = azurerm_disk_encryption_set.des.id
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-datacenter-g2"
    version   = "latest"
  }
}

##################################################
# DEV02 VM
##################################################

resource "azurerm_windows_virtual_machine" "dev02" {

  name          = "mophazddhp02"
  computer_name = "mophazddhp02"

  location            = azurerm_resource_group.rgdev.location
  resource_group_name = azurerm_resource_group.rgdev.name

  # zone                = "2"

  size = "Standard_D4s_v5"

  admin_username = "mophazadmin"
  admin_password = var.admin_password

  license_type = local.windows_license_type

  network_interface_ids = [
    azurerm_network_interface.dev02_nic.id
  ]

  encryption_at_host_enabled = true
  secure_boot_enabled        = true
  vtpm_enabled               = true

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                   = "mophazddhp02-osdisk"
    caching                = "ReadWrite"
    storage_account_type   = "StandardSSD_LRS"
    disk_size_gb           = 200
    disk_encryption_set_id = azurerm_disk_encryption_set.des.id
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-datacenter-g2"
    version   = "latest"
  }
}

##################################################
# DB01 VM
##################################################

resource "azurerm_windows_virtual_machine" "db01" {

  name          = "mophazddhpdb01"
  computer_name = "mophazddhpdb01"

  location            = azurerm_resource_group.rgdev.location
  resource_group_name = azurerm_resource_group.rgdev.name

  # zone                = "1"

  size = "Standard_D4s_v5"

  admin_username = "mophazadmin"
  admin_password = var.admin_password

  license_type = local.windows_license_type

  network_interface_ids = [
    azurerm_network_interface.db01_nic.id
  ]

  encryption_at_host_enabled = true
  secure_boot_enabled        = true
  vtpm_enabled               = true

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                   = "mophazddhpdb01-osdisk"
    caching                = "ReadWrite"
    storage_account_type   = "StandardSSD_LRS"
    disk_size_gb           = 200
    disk_encryption_set_id = azurerm_disk_encryption_set.des.id
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-datacenter-g2"
    version   = "latest"
  }
}



##################################################
# DB01 VM
##################################################

resource "azurerm_windows_virtual_machine" "db02" {

  name          = "mophazddhpdb02"
  computer_name = "mophazddhpdb02"

  location            = azurerm_resource_group.rgdev.location
  resource_group_name = azurerm_resource_group.rgdev.name

  # zone                = "1"

  size = "Standard_D4s_v5"

  admin_username = "mophazadmin"
  admin_password = var.admin_password

  license_type = local.windows_license_type

  network_interface_ids = [
    azurerm_network_interface.db02_nic.id
  ]

  encryption_at_host_enabled = true
  secure_boot_enabled        = true
  vtpm_enabled               = true

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                   = "mophazddhpdb02-osdisk"
    caching                = "ReadWrite"
    storage_account_type   = "StandardSSD_LRS"
    disk_size_gb           = 200
    disk_encryption_set_id = azurerm_disk_encryption_set.des.id
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-datacenter-g2"
    version   = "latest"
  }
}
##################################################
# DEV01 DATA DISK
##################################################

resource "azurerm_managed_disk" "dev01_data" {
  name                = "mophazddhp01-data"
  location            = azurerm_resource_group.rgdev.location
  resource_group_name = azurerm_resource_group.rgdev.name

  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 500

  disk_encryption_set_id = azurerm_disk_encryption_set.des.id
}

resource "azurerm_virtual_machine_data_disk_attachment" "dev01_data" {
  managed_disk_id    = azurerm_managed_disk.dev01_data.id
  virtual_machine_id = azurerm_windows_virtual_machine.dev01.id

  lun     = 0
  caching = "ReadWrite"
}


resource "azurerm_managed_disk" "dev02_data" {
  name                = "mophazddhp02-data"
  location            = azurerm_resource_group.rgdev.location
  resource_group_name = azurerm_resource_group.rgdev.name

  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 500

  disk_encryption_set_id = azurerm_disk_encryption_set.des.id
}

resource "azurerm_virtual_machine_data_disk_attachment" "dev02_data" {
  managed_disk_id    = azurerm_managed_disk.dev02_data.id
  virtual_machine_id = azurerm_windows_virtual_machine.dev02.id

  lun     = 0
  caching = "ReadWrite"
}

resource "azurerm_managed_disk" "dev01_log" {
  name                = "mophazddhp01-log"
  location            = azurerm_resource_group.rgdev.location
  resource_group_name = azurerm_resource_group.rgdev.name

  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 80

  disk_encryption_set_id = azurerm_disk_encryption_set.des.id
}

resource "azurerm_managed_disk" "dev02_log" {
  name                = "mophazddhp02-log"
  location            = azurerm_resource_group.rgdev.location
  resource_group_name = azurerm_resource_group.rgdev.name

  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 80

  disk_encryption_set_id = azurerm_disk_encryption_set.des.id
}

resource "azurerm_virtual_machine_data_disk_attachment" "dev01_log" {
  managed_disk_id    = azurerm_managed_disk.dev01_log.id
  virtual_machine_id = azurerm_windows_virtual_machine.dev01.id

  lun     = 1
  caching = "None"
}

resource "azurerm_virtual_machine_data_disk_attachment" "dev02_log" {
  managed_disk_id    = azurerm_managed_disk.dev02_log.id
  virtual_machine_id = azurerm_windows_virtual_machine.dev02.id

  lun     = 1
  caching = "None"
}

##################################################
# DB01 DATA DISK
##################################################

resource "azurerm_managed_disk" "db01_data" {
  name                = "mophazddhpdb01-data"
  location            = azurerm_resource_group.rgdev.location
  resource_group_name = azurerm_resource_group.rgdev.name

  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 2500

  disk_encryption_set_id = azurerm_disk_encryption_set.des.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "db01_data" {
  managed_disk_id    = azurerm_managed_disk.db01_data.id
  virtual_machine_id = azurerm_windows_virtual_machine.db01.id

  lun     = 1
  caching = "None"
}

resource "azurerm_managed_disk" "db01_log" {
  name                = "mophazddhpdb01-log"
  location            = azurerm_resource_group.rgdev.location
  resource_group_name = azurerm_resource_group.rgdev.name

  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 700

  disk_encryption_set_id = azurerm_disk_encryption_set.des.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "db01_log" {
  managed_disk_id    = azurerm_managed_disk.db01_log.id
  virtual_machine_id = azurerm_windows_virtual_machine.db01.id

  lun     = 2
  caching = "None"
}

resource "azurerm_managed_disk" "db01_temp" {
  name                = "mophazddhpdb01-temp"
  location            = azurerm_resource_group.rgdev.location
  resource_group_name = azurerm_resource_group.rgdev.name

  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 300

  disk_encryption_set_id = azurerm_disk_encryption_set.des.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "db01_temp" {
  managed_disk_id    = azurerm_managed_disk.db01_temp.id
  virtual_machine_id = azurerm_windows_virtual_machine.db01.id

  lun     = 3
  caching = "None"
}