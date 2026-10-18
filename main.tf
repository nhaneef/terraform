locals {
  environments = {
    prod = {
      environment_name = "Production"

      resource_group_name = "rg-qndis-avs-prod-001"
      vnet_name           = "vnet-qndis-prod-qc-001"
      subnet_name         = "snet-qndis-prod-jump-qc-001"

      nsg_name = "nsg-qndis-prod-jump-qc-001"

      managed_identity_name = "id-qndis-jmp-prd-qc-001"
      key_vault_name        = "kv-qndis-jmp-prd-qc-001"
      cmk_name              = "cmk-qndis-prd-qc-001"
      des_name              = "des-qndis-jmp-prd-qc-001"

      vm_name      = "vmqndisjmpprdqc01"
      nic_name     = "nic-vmqndisjmpprdqc01"
      os_disk_name = "osdisk-vmqndisjmpprdqc01"
    }

    test = {
      environment_name = "Test"

      resource_group_name = "rg-qndis-test-env-001"
      vnet_name           = "vnet-qndis-test-qc-001"
      subnet_name         = "snet-qndis-test-jump-qc-001"

      nsg_name = "nsg-qndis-test-jump-qc-001"

      managed_identity_name = "id-qndis-jmp-tst-qc-001"
      key_vault_name        = "kv-qndis-jmp-tst-qc-001"
      cmk_name              = "cmk-qndis-tst-qc-001"
      des_name              = "des-qndis-jmp-tst-qc-001"

      vm_name      = "vmqndisjmptstqc01"
      nic_name     = "nic-vmqndisjmptstqc01"
      os_disk_name = "osdisk-vmqndisjmptstqc01"
    }
  }

  vm_administrator_assignments = flatten([
    for environment_key, environment in local.environments : [
      for group_object_id in var.vm_administrator_group_object_ids : {
        key             = "${environment_key}-${group_object_id}"
        environment_key = environment_key
        group_object_id = group_object_id
      }
    ]
  ])

  vm_user_assignments = flatten([
    for environment_key, environment in local.environments : [
      for group_object_id in var.vm_user_group_object_ids : {
        key             = "${environment_key}-${group_object_id}"
        environment_key = environment_key
        group_object_id = group_object_id
      }
    ]
  ])
}


