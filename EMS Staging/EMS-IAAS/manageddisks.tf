########################################
# STAGING DATA DISK DEFINITIONS
########################################

locals {
  staging_data_disks = {
    ####################################
    # DB01 - MOPHAZEMSSDB01
    ####################################

    db01_mdf = {
      name         = "MOPHAZEMSSDB01-MDF"
      vm_key       = "db01"
      size_gb      = 128
      storage_type = "Premium_LRS"
      lun          = 0
      caching      = "ReadOnly"
      zone         = "1"
    }

    db01_ldf = {
      name         = "MOPHAZEMSSDB01-LDF"
      vm_key       = "db01"
      size_gb      = 256
      storage_type = "Premium_LRS"
      lun          = 1
      caching      = "None"
      zone         = "1"
    }

    db01_tempdb_mdf = {
      name         = "MOPHAZEMSSDB01-TEMPDB-MDF"
      vm_key       = "db01"
      size_gb      = 128
      storage_type = "Premium_LRS"
      lun          = 2
      caching      = "ReadOnly"
      zone         = "1"
    }

    db01_tempdb_ldf = {
      name         = "MOPHAZEMSSDB01-TEMPDB-LDF"
      vm_key       = "db01"
      size_gb      = 128
      storage_type = "Premium_LRS"
      lun          = 3
      caching      = "None"
      zone         = "1"
    }

    db01_systemdb = {
      name         = "MOPHAZEMSSDB01-SYSTEMDB"
      vm_key       = "db01"
      size_gb      = 128
      storage_type = "Premium_LRS"
      lun          = 4
      caching      = "None"
      zone         = "1"
    }

    ####################################
    # DB02 - MOPHAZEMSSDB02
    ####################################

    db02_mdf = {
      name         = "MOPHAZEMSSDB02-MDF"
      vm_key       = "db02"
      size_gb      = 128
      storage_type = "Premium_LRS"
      lun          = 0
      caching      = "ReadOnly"
      zone         = "2"
    }

    db02_ldf = {
      name         = "MOPHAZEMSSDB02-LDF"
      vm_key       = "db02"
      size_gb      = 256
      storage_type = "Premium_LRS"
      lun          = 1
      caching      = "None"
      zone         = "2"
    }

    db02_tempdb_mdf = {
      name         = "MOPHAZEMSSDB02-TEMPDB-MDF"
      vm_key       = "db02"
      size_gb      = 128
      storage_type = "Premium_LRS"
      lun          = 2
      caching      = "ReadOnly"
      zone         = "2"
    }

    db02_tempdb_ldf = {
      name         = "MOPHAZEMSSDB02-TEMPDB-LDF"
      vm_key       = "db02"
      size_gb      = 128
      storage_type = "Premium_LRS"
      lun          = 3
      caching      = "None"
      zone         = "2"
    }

    db02_systemdb = {
      name         = "MOPHAZEMSSDB02-SYSTEMDB"
      vm_key       = "db02"
      size_gb      = 128
      storage_type = "Premium_LRS"
      lun          = 4
      caching      = "None"
      zone         = "2"
    }

    ####################################
    # APP01 - MOPHAZEMSSAPP01
    ####################################

    app01_application = {
      name         = "MOPHAZEMSSAPP01-APP"
      vm_key       = "app01"
      size_gb      = 128
      storage_type = "StandardSSD_LRS"
      lun          = 0
      caching      = "ReadWrite"
      zone         = "1"
    }

    app01_backup = {
      name         = "MOPHAZEMSSAPP01-BACKUP"
      vm_key       = "app01"
      size_gb      = 128
      storage_type = "StandardSSD_LRS"
      lun          = 1
      caching      = "None"
      zone         = "1"
    }

    app01_cache = {
      name         = "MOPHAZEMSSAPP01-CACHE"
      vm_key       = "app01"
      size_gb      = 128
      storage_type = "StandardSSD_LRS"
      lun          = 2
      caching      = "ReadWrite"
      zone         = "1"
    }

    app01_logs = {
      name         = "MOPHAZEMSSAPP01-LOGS"
      vm_key       = "app01"
      size_gb      = 128
      storage_type = "StandardSSD_LRS"
      lun          = 3
      caching      = "None"
      zone         = "1"
    }

    ####################################
    # APP02 - MOPHAZEMSSAPP02
    ####################################

    app02_application = {
      name         = "MOPHAZEMSSAPP02-APP"
      vm_key       = "app02"
      size_gb      = 128
      storage_type = "StandardSSD_LRS"
      lun          = 0
      caching      = "ReadWrite"
      zone         = "2"
    }

    app02_backup = {
      name         = "MOPHAZEMSSAPP02-BACKUP"
      vm_key       = "app02"
      size_gb      = 128
      storage_type = "StandardSSD_LRS"
      lun          = 1
      caching      = "None"
      zone         = "2"
    }

    app02_cache = {
      name         = "MOPHAZEMSSAPP02-CACHE"
      vm_key       = "app02"
      size_gb      = 128
      storage_type = "StandardSSD_LRS"
      lun          = 2
      caching      = "ReadWrite"
      zone         = "2"
    }

    app02_logs = {
      name         = "MOPHAZEMSSAPP02-LOGS"
      vm_key       = "app02"
      size_gb      = 128
      storage_type = "StandardSSD_LRS"
      lun          = 3
      caching      = "None"
      zone         = "2"
    }

    ####################################
    # WFE01 - MOPHAZEMSSWFE01
    ####################################

    wfe01_application = {
      name         = "MOPHAZEMSSWFE01-APP"
      vm_key       = "wfe01"
      size_gb      = 128
      storage_type = "StandardSSD_LRS"
      lun          = 0
      caching      = "ReadWrite"
      zone         = "1"
    }

    wfe01_backup = {
      name         = "MOPHAZEMSSWFE01-BACKUP"
      vm_key       = "wfe01"
      size_gb      = 128
      storage_type = "StandardSSD_LRS"
      lun          = 1
      caching      = "None"
      zone         = "1"
    }

    wfe01_cache = {
      name         = "MOPHAZEMSSWFE01-CACHE"
      vm_key       = "wfe01"
      size_gb      = 128
      storage_type = "StandardSSD_LRS"
      lun          = 2
      caching      = "ReadWrite"
      zone         = "1"
    }

    wfe01_logs = {
      name         = "MOPHAZEMSSWFE01-LOGS"
      vm_key       = "wfe01"
      size_gb      = 128
      storage_type = "StandardSSD_LRS"
      lun          = 3
      caching      = "None"
      zone         = "1"
    }

    ####################################
    # WFE02 - MOPHAZEMSSWFE02
    ####################################

    wfe02_application = {
      name         = "MOPHAZEMSSWFE02-APP"
      vm_key       = "wfe02"
      size_gb      = 128
      storage_type = "StandardSSD_LRS"
      lun          = 0
      caching      = "ReadWrite"
      zone         = "2"
    }

    wfe02_backup = {
      name         = "MOPHAZEMSSWFE02-BACKUP"
      vm_key       = "wfe02"
      size_gb      = 128
      storage_type = "StandardSSD_LRS"
      lun          = 1
      caching      = "None"
      zone         = "2"
    }

    wfe02_cache = {
      name         = "MOPHAZEMSSWFE02-CACHE"
      vm_key       = "wfe02"
      size_gb      = 128
      storage_type = "StandardSSD_LRS"
      lun          = 2
      caching      = "ReadWrite"
      zone         = "2"
    }

    wfe02_logs = {
      name         = "MOPHAZEMSSWFE02-LOGS"
      vm_key       = "wfe02"
      size_gb      = 128
      storage_type = "StandardSSD_LRS"
      lun          = 3
      caching      = "None"
      zone         = "2"
    }
  }

  ######################################
  # VM RESOURCE MAPPING
  ######################################

  staging_vm_ids = {
    db01  = azurerm_windows_virtual_machine.db01.id
    db02  = azurerm_windows_virtual_machine.db02.id
    app01 = azurerm_windows_virtual_machine.app01.id
    app02 = azurerm_windows_virtual_machine.app02.id
    wfe01 = azurerm_windows_virtual_machine.wfe01.id
    wfe02 = azurerm_windows_virtual_machine.wfe02.id
  }
}

########################################
# CREATE STAGING MANAGED DATA DISKS
########################################

resource "azurerm_managed_disk" "staging_data_disks" {
  for_each = local.staging_data_disks

  name                 = each.value.name
  location             = "qatarcentral"
  resource_group_name  = "rg-ems-onprem-iaas-stg-qc-001"
  storage_account_type = each.value.storage_type
  create_option        = "Empty"
  disk_size_gb         = each.value.size_gb
  zone                 = each.value.zone

  disk_encryption_set_id = data.azurerm_disk_encryption_set.des.id
}

########################################
# ATTACH STAGING DATA DISKS
########################################

resource "azurerm_virtual_machine_data_disk_attachment" "staging_data_disks" {
  for_each = local.staging_data_disks

  managed_disk_id    = azurerm_managed_disk.staging_data_disks[each.key].id
  virtual_machine_id = local.staging_vm_ids[each.value.vm_key]
  lun                = each.value.lun
  caching            = each.value.caching
}


########################################
# SHARED QUORUM DISK
########################################

resource "azurerm_managed_disk" "db_shared_disk" {
  name                = "MOPHAZEMSSDB-QUORUM"
  location            = "qatarcentral"
  resource_group_name = "rg-ems-onprem-iaas-stg-qc-001"

  storage_account_type = "StandardSSD_ZRS"
  create_option        = "Empty"
  disk_size_gb         = 4

  max_shares = 2

  disk_encryption_set_id = data.azurerm_disk_encryption_set.des.id
}

resource "azurerm_virtual_machine_data_disk_attachment" "db01_shared_disk" {
  managed_disk_id    = azurerm_managed_disk.db_shared_disk.id
  virtual_machine_id = azurerm_windows_virtual_machine.db01.id

  lun     = 5
  caching = "None"
}

resource "azurerm_virtual_machine_data_disk_attachment" "db02_shared_disk" {
  managed_disk_id    = azurerm_managed_disk.db_shared_disk.id
  virtual_machine_id = azurerm_windows_virtual_machine.db02.id

  lun     = 5
  caching = "None"
}