##################################################
# Network Interfaces
##################################################
resource "azurerm_network_interface" "stgapp01_nic" {
  name                = "mophazsdhpapp01-nic"
  location            = azurerm_resource_group.rgstg.location
  resource_group_name = azurerm_resource_group.rgstg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.app.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "stgapp02_nic" {
  name                = "mophazsdhpapp02-nic"
  location            = azurerm_resource_group.rgstg.location
  resource_group_name = azurerm_resource_group.rgstg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.app.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "stgwfe01_nic" {
  name                = "mophazsdhpwfe01-nic"
  location            = azurerm_resource_group.rgstg.location
  resource_group_name = azurerm_resource_group.rgstg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.wfe.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "stgwfe02_nic" {
  name                = "mophazsdhpwfe02-nic"
  location            = azurerm_resource_group.rgstg.location
  resource_group_name = azurerm_resource_group.rgstg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.wfe.id
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_network_interface" "stgdb01_nic" {
  name                = "mophazsdhpdb01-nic"
  location            = azurerm_resource_group.rgstg.location
  resource_group_name = azurerm_resource_group.rgstg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.db.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "stgdb02_nic" {
  name                = "mophazsdhpdb02-nic"
  location            = azurerm_resource_group.rgstg.location
  resource_group_name = azurerm_resource_group.rgstg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.db.id
    private_ip_address_allocation = "Dynamic"
  }
}

##################################################
# Windows Virtual Machines
##################################################

resource "azurerm_windows_virtual_machine" "stgapp01" {
  name                = "mophazsdhpapp01"
  computer_name       = "mophazsdhpapp01"
  location            = azurerm_resource_group.rgstg.location
  resource_group_name = azurerm_resource_group.rgstg.name
  size                = "Standard_D4s_v5"
  admin_username      = "mophazadmin"
  admin_password      = var.admin_password
  license_type        = local.windows_license_type

  network_interface_ids = [azurerm_network_interface.stgapp01_nic.id]

  encryption_at_host_enabled = true
  secure_boot_enabled        = true
  vtpm_enabled               = true

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                   = "mophazsdhpapp01-osdisk"
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

resource "azurerm_windows_virtual_machine" "stgapp02" {
  name                = "mophazsdhpapp02"
  computer_name       = "mophazsdhpapp02"
  location            = azurerm_resource_group.rgstg.location
  resource_group_name = azurerm_resource_group.rgstg.name
  size                = "Standard_D4s_v5"
  admin_username      = "mophazadmin"
  admin_password      = var.admin_password
  license_type        = local.windows_license_type

  network_interface_ids = [azurerm_network_interface.stgapp02_nic.id]

  encryption_at_host_enabled = true
  secure_boot_enabled        = true
  vtpm_enabled               = true

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                   = "mophazsdhpapp02-osdisk"
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

resource "azurerm_windows_virtual_machine" "stgwfe01" {
  name                = "mophazsdhpwfe01"
  computer_name       = "mophazsdhpwfe01"
  location            = azurerm_resource_group.rgstg.location
  resource_group_name = azurerm_resource_group.rgstg.name
  size                = "Standard_D8s_v5"
  admin_username      = "mophazadmin"
  admin_password      = var.admin_password
  license_type        = local.windows_license_type

  network_interface_ids = [azurerm_network_interface.stgwfe01_nic.id]

  encryption_at_host_enabled = true
  secure_boot_enabled        = true
  vtpm_enabled               = true

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                   = "mophazsdhpwfe01-osdisk"
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

resource "azurerm_windows_virtual_machine" "stgwfe02" {
  name                = "mophazsdhpwfe02"
  computer_name       = "mophazsdhpwfe02"
  location            = azurerm_resource_group.rgstg.location
  resource_group_name = azurerm_resource_group.rgstg.name
  size                = "Standard_D8s_v5"
  admin_username      = "mophazadmin"
  admin_password      = var.admin_password
  license_type        = local.windows_license_type

  network_interface_ids = [azurerm_network_interface.stgwfe02_nic.id]

  encryption_at_host_enabled = true
  secure_boot_enabled        = true
  vtpm_enabled               = true

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                   = "mophazsdhpwfe02-osdisk"
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


resource "azurerm_windows_virtual_machine" "stgdb01" {
  name                = "mophazsdhpdb01"
  computer_name       = "mophazsdhpdb01"
  location            = azurerm_resource_group.rgstg.location
  resource_group_name = azurerm_resource_group.rgstg.name
  size                = "Standard_D4s_v5"
  admin_username      = "mophazadmin"
  admin_password      = var.admin_password
  license_type        = local.windows_license_type

  network_interface_ids = [azurerm_network_interface.stgapp01_nic.id]

  encryption_at_host_enabled = true
  secure_boot_enabled        = true
  vtpm_enabled               = true

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                   = "mophazsdhpdb01-osdisk"
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


resource "azurerm_windows_virtual_machine" "stgdb02" {
  name                = "mophazsdhpdb02"
  computer_name       = "mophazsdhpdb02"
  location            = azurerm_resource_group.rgstg.location
  resource_group_name = azurerm_resource_group.rgstg.name
  size                = "Standard_D4s_v5"
  admin_username      = "mophazadmin"
  admin_password      = var.admin_password
  license_type        = local.windows_license_type

  network_interface_ids = [azurerm_network_interface.stgapp01_nic.id]

  encryption_at_host_enabled = true
  secure_boot_enabled        = true
  vtpm_enabled               = true

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                   = "mophazsdhpdb02-osdisk"
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
# Managed Data Disks - 500 GB, LUN 0
##################################################

resource "azurerm_managed_disk" "stgapp01_data" {
  name                   = "mophazsdhpapp01-data"
  location               = azurerm_resource_group.rgstg.location
  resource_group_name    = azurerm_resource_group.rgstg.name
  storage_account_type   = "Standard_LRS"
  create_option          = "Empty"
  disk_size_gb           = 500
  disk_encryption_set_id = azurerm_disk_encryption_set.des.id
}

resource "azurerm_managed_disk" "stgapp02_data" {
  name                   = "mophazsdhpapp02-data"
  location               = azurerm_resource_group.rgstg.location
  resource_group_name    = azurerm_resource_group.rgstg.name
  storage_account_type   = "Standard_LRS"
  create_option          = "Empty"
  disk_size_gb           = 500
  disk_encryption_set_id = azurerm_disk_encryption_set.des.id
}

resource "azurerm_managed_disk" "stgwfe01_data" {
  name                   = "mophazsdhpwfe01-data"
  location               = azurerm_resource_group.rgstg.location
  resource_group_name    = azurerm_resource_group.rgstg.name
  storage_account_type   = "Standard_LRS"
  create_option          = "Empty"
  disk_size_gb           = 500
  disk_encryption_set_id = azurerm_disk_encryption_set.des.id
}

resource "azurerm_managed_disk" "stgwfe02_data" {
  name                   = "mophazsdhpwfe02-data"
  location               = azurerm_resource_group.rgstg.location
  resource_group_name    = azurerm_resource_group.rgstg.name
  storage_account_type   = "Standard_LRS"
  create_option          = "Empty"
  disk_size_gb           = 500
  disk_encryption_set_id = azurerm_disk_encryption_set.des.id
}

resource "azurerm_managed_disk" "stgdb01_data" {
  name                   = "mophazsdhpdb01-data"
  location               = azurerm_resource_group.rgstg.location
  resource_group_name    = azurerm_resource_group.rgstg.name
  storage_account_type   = "Standard_LRS"
  create_option          = "Empty"
  disk_size_gb           = 2500
  disk_encryption_set_id = azurerm_disk_encryption_set.des.id
}

resource "azurerm_managed_disk" "stgdb02_data" {
  name                   = "mophazsdhpdb02-data"
  location               = azurerm_resource_group.rgstg.location
  resource_group_name    = azurerm_resource_group.rgstg.name
  storage_account_type   = "Standard_LRS"
  create_option          = "Empty"
  disk_size_gb           = 2500
  disk_encryption_set_id = azurerm_disk_encryption_set.des.id
}

resource "azurerm_virtual_machine_data_disk_attachment" "stgapp01_data" {
  managed_disk_id    = azurerm_managed_disk.stgapp01_data.id
  virtual_machine_id = azurerm_windows_virtual_machine.stgapp01.id
  lun                = 0
  caching            = "ReadWrite"
}

resource "azurerm_virtual_machine_data_disk_attachment" "stgapp02_data" {
  managed_disk_id    = azurerm_managed_disk.stgapp02_data.id
  virtual_machine_id = azurerm_windows_virtual_machine.stgapp02.id
  lun                = 0
  caching            = "ReadWrite"
}

resource "azurerm_virtual_machine_data_disk_attachment" "stgwfe01_data" {
  managed_disk_id    = azurerm_managed_disk.stgwfe01_data.id
  virtual_machine_id = azurerm_windows_virtual_machine.stgwfe01.id
  lun                = 0
  caching            = "ReadWrite"
}

resource "azurerm_virtual_machine_data_disk_attachment" "stgwfe02_data" {
  managed_disk_id    = azurerm_managed_disk.stgwfe02_data.id
  virtual_machine_id = azurerm_windows_virtual_machine.stgwfe02.id
  lun                = 0
  caching            = "ReadWrite"
}

resource "azurerm_virtual_machine_data_disk_attachment" "stgdb01_data" {
  managed_disk_id    = azurerm_managed_disk.stgdb01_data.id
  virtual_machine_id = azurerm_windows_virtual_machine.stgapp01.id
  lun                = 0
  caching            = "ReadWrite"
}

resource "azurerm_virtual_machine_data_disk_attachment" "stgdb02_data" {
  managed_disk_id    = azurerm_managed_disk.stgdb02_data.id
  virtual_machine_id = azurerm_windows_virtual_machine.stgdb02.id
  lun                = 0
  caching            = "ReadWrite"
}



##################################################
# Managed Log Disks - 80 GB, LUN 1
##################################################

resource "azurerm_managed_disk" "stgapp01_log" {
  name                   = "mophazsdhpapp01-log"
  location               = azurerm_resource_group.rgstg.location
  resource_group_name    = azurerm_resource_group.rgstg.name
  storage_account_type   = "Standard_LRS"
  create_option          = "Empty"
  disk_size_gb           = 80
  disk_encryption_set_id = azurerm_disk_encryption_set.des.id
}

resource "azurerm_managed_disk" "stgapp02_log" {
  name                   = "mophazsdhpapp02-log"
  location               = azurerm_resource_group.rgstg.location
  resource_group_name    = azurerm_resource_group.rgstg.name
  storage_account_type   = "Standard_LRS"
  create_option          = "Empty"
  disk_size_gb           = 80
  disk_encryption_set_id = azurerm_disk_encryption_set.des.id
}

resource "azurerm_managed_disk" "stgwfe01_log" {
  name                   = "mophazsdhpwfe01-log"
  location               = azurerm_resource_group.rgstg.location
  resource_group_name    = azurerm_resource_group.rgstg.name
  storage_account_type   = "Standard_LRS"
  create_option          = "Empty"
  disk_size_gb           = 80
  disk_encryption_set_id = azurerm_disk_encryption_set.des.id
}

resource "azurerm_managed_disk" "stgwfe02_log" {
  name                   = "mophazsdhpwfe02-log"
  location               = azurerm_resource_group.rgstg.location
  resource_group_name    = azurerm_resource_group.rgstg.name
  storage_account_type   = "Standard_LRS"
  create_option          = "Empty"
  disk_size_gb           = 80
  disk_encryption_set_id = azurerm_disk_encryption_set.des.id
}
resource "azurerm_managed_disk" "stgdb01_log" {
  name                   = "mophazsdhpdb01-log"
  location               = azurerm_resource_group.rgstg.location
  resource_group_name    = azurerm_resource_group.rgstg.name
  storage_account_type   = "Standard_LRS"
  create_option          = "Empty"
  disk_size_gb           = 600
  disk_encryption_set_id = azurerm_disk_encryption_set.des.id
}


resource "azurerm_managed_disk" "stgdb02_log" {
  name                   = "mophazsdhpdb02-log"
  location               = azurerm_resource_group.rgstg.location
  resource_group_name    = azurerm_resource_group.rgstg.name
  storage_account_type   = "Standard_LRS"
  create_option          = "Empty"
  disk_size_gb           = 600
  disk_encryption_set_id = azurerm_disk_encryption_set.des.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "stgapp01_log" {
  managed_disk_id    = azurerm_managed_disk.stgapp01_log.id
  virtual_machine_id = azurerm_windows_virtual_machine.stgapp01.id
  lun                = 1
  caching            = "None"
}

resource "azurerm_virtual_machine_data_disk_attachment" "stgapp02_log" {
  managed_disk_id    = azurerm_managed_disk.stgapp02_log.id
  virtual_machine_id = azurerm_windows_virtual_machine.stgapp02.id
  lun                = 1
  caching            = "None"
}

resource "azurerm_virtual_machine_data_disk_attachment" "stgwfe01_log" {
  managed_disk_id    = azurerm_managed_disk.stgwfe01_log.id
  virtual_machine_id = azurerm_windows_virtual_machine.stgwfe01.id
  lun                = 1
  caching            = "None"
}

resource "azurerm_virtual_machine_data_disk_attachment" "stgwfe02_log" {
  managed_disk_id    = azurerm_managed_disk.stgwfe02_log.id
  virtual_machine_id = azurerm_windows_virtual_machine.stgwfe02.id
  lun                = 1
  caching            = "None"
}

resource "azurerm_virtual_machine_data_disk_attachment" "stgdb01_log" {
  managed_disk_id    = azurerm_managed_disk.stgdb01_log.id
  virtual_machine_id = azurerm_windows_virtual_machine.stgdb01.id
  lun                = 1
  caching            = "None"
}

resource "azurerm_virtual_machine_data_disk_attachment" "stgdb02_log" {
  managed_disk_id    = azurerm_managed_disk.stgdb02_log.id
  virtual_machine_id = azurerm_windows_virtual_machine.stgdb02.id
  lun                = 1
  caching            = "None"
}
#################################################################
# tEMP dISKS
#################################################################

resource "azurerm_managed_disk" "stgdb01_temp" {
  name                   = "mophazsdhpdb01-temp"
  location               = azurerm_resource_group.rgstg.location
  resource_group_name    = azurerm_resource_group.rgstg.name
  storage_account_type   = "Standard_LRS"
  create_option          = "Empty"
  disk_size_gb           = 300
  disk_encryption_set_id = azurerm_disk_encryption_set.des.id
}
resource "azurerm_managed_disk" "stgdb02_temp" {
  name                   = "mophazsdhpdb02-temp"
  location               = azurerm_resource_group.rgstg.location
  resource_group_name    = azurerm_resource_group.rgstg.name
  storage_account_type   = "Standard_LRS"
  create_option          = "Empty"
  disk_size_gb           = 300
  disk_encryption_set_id = azurerm_disk_encryption_set.des.id
}
  resource "azurerm_virtual_machine_data_disk_attachment" "stgdb01_temp" {
  managed_disk_id    = azurerm_managed_disk.stgdb01_log.id
  virtual_machine_id = azurerm_windows_virtual_machine.stgdb01.id
  lun                = 1
  caching            = "None"
}

resource "azurerm_virtual_machine_data_disk_attachment" "stgdb02_temp" {
  managed_disk_id    = azurerm_managed_disk.stgdb02_log.id
  virtual_machine_id = azurerm_windows_virtual_machine.stgdb02.id
  lun                = 1
  caching            = "None"
}