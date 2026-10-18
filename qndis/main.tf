locals {

  environments = {

    prod = {
      rg     = "rg-qndis-avs-prod-001"
      vnet   = "vnet-qndis-prod-qc-001"
      subnet = "snet-qndis-prod-jump-qc-001"

      nsg = "nsg-qndis-prod-jump-qc-001"

      nic = "nic-vmqndisjmpprd01"
      vm  = "vmqndisjmpprd01"
    }

    test = {
      rg     = "rg-qndis-test-env-001"
      vnet   = "vnet-qndis-test-qc-001"
      subnet = "snet-qndis-test-jump-qc-001"

      nsg = "nsg-qndis-test-jump-qc-001"

      nic = "nic-vmqndisjmptst01"
      vm  = "vmqndisjmptst01"
    }
  }
}

#
# Existing Resource Groups
#

data "azurerm_resource_group" "rg" {
  for_each = local.environments

  name = each.value.rg
}

#
# Existing Subnets
#

data "azurerm_subnet" "subnet" {
  for_each = local.environments

  name                 = each.value.subnet
  virtual_network_name = each.value.vnet
  resource_group_name  = each.value.rg
}

#
# NSG
#

resource "azurerm_network_security_group" "nsg" {

  for_each = local.environments

  name                = each.value.nsg
  location            = data.azurerm_resource_group.rg[each.key].location
  resource_group_name = data.azurerm_resource_group.rg[each.key].name
}

#
# NSG Association
#

resource "azurerm_subnet_network_security_group_association" "nsg" {

  for_each = local.environments

  subnet_id                 = data.azurerm_subnet.subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}

#
# NIC
#

resource "azurerm_network_interface" "nic" {

  for_each = local.environments

  name                = each.value.nic
  location            = data.azurerm_resource_group.rg[each.key].location
  resource_group_name = data.azurerm_resource_group.rg[each.key].name

  accelerated_networking_enabled = true

  ip_configuration {
    name                          = "ipconfig01"
    subnet_id                     = data.azurerm_subnet.subnet[each.key].id
    private_ip_address_allocation = "Dynamic"
  }
}

#
# VM
#

resource "azurerm_windows_virtual_machine" "vm" {

  for_each = local.environments

  name                = each.value.vm
  computer_name       = each.value.vm
  location            = data.azurerm_resource_group.rg[each.key].location
  resource_group_name = data.azurerm_resource_group.rg[each.key].name

  size = "Standard_D4ds_v5"

  # zone = "1"
  encryption_at_host_enabled = true
  admin_username = var.admin_username
  admin_password = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.nic[each.key].id
  ]

  secure_boot_enabled = false
  vtpm_enabled        = false

  patch_mode = "AutomaticByPlatform"

  identity {
    type = "SystemAssigned"
  }

  os_disk {

    name = "${each.value.vm}-osdisk"

    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 128
  }

  source_image_reference {

    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"

    sku = "2025-datacenter"

    version = "latest"
  }
}

#
# Entra Login
#

resource "azurerm_virtual_machine_extension" "aadlogin" {

  for_each = local.environments

  name               = "AADLoginForWindows"
  virtual_machine_id = azurerm_windows_virtual_machine.vm[each.key].id

  publisher            = "Microsoft.Azure.ActiveDirectory"
  type                 = "AADLoginForWindows"
  type_handler_version = "2.2"
}