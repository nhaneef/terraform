##################################################
# Current Client
##################################################

data "azurerm_client_config" "current" {}

##################################################
# User Assigned Managed Identity
##################################################

resource "azurerm_user_assigned_identity" "uami" {

  for_each = local.environments

  name = each.key == "prod" ? (
    "id-qndis-jmp-prd-qc-001"
  ) : (
    "id-qndis-jmp-tst-qc-001"
  )

  location            = data.azurerm_resource_group.rg[each.key].location
  resource_group_name = data.azurerm_resource_group.rg[each.key].name
}

##################################################
# Key Vault
##################################################

resource "azurerm_key_vault" "kv" {

  for_each = local.environments

  name = each.key == "prod" ? (
    "kv-qndis-jmp-prd-qc-001"
  ) : (
    "kv-qndis-jmp-tst-qc-001"
  )

  location            = data.azurerm_resource_group.rg[each.key].location
  resource_group_name = data.azurerm_resource_group.rg[each.key].name

  tenant_id = data.azurerm_client_config.current.tenant_id

  sku_name = "premium"

  rbac_authorization_enabled  = true

  purge_protection_enabled   = true
  soft_delete_retention_days = 90

  public_network_access_enabled = true
}

##################################################
# Allow Terraform to Manage Keys
##################################################

resource "azurerm_role_assignment" "kv_admin" {

  for_each = local.environments

  scope                = azurerm_key_vault.kv[each.key].id
  role_definition_name = "Key Vault Administrator"

  principal_id = data.azurerm_client_config.current.object_id
}

##################################################
# Customer Managed Key
##################################################

resource "azurerm_key_vault_key" "cmk" {

  for_each = local.environments

  name = each.key == "prod" ? (
    "cmk-qndis-prd-qc-001"
  ) : (
    "cmk-qndis-tst-qc-001"
  )

  key_vault_id = azurerm_key_vault.kv[each.key].id

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

##################################################
# Grant Managed Identity Access To CMK
##################################################

resource "azurerm_role_assignment" "crypto_user" {

  for_each = local.environments

  scope                = azurerm_key_vault.kv[each.key].id
  role_definition_name = "Key Vault Crypto Service Encryption User"

  principal_id =  azurerm_user_assigned_identity.uami[each.key].principal_id

  skip_service_principal_aad_check = true
}

##################################################
# Disk Encryption Set
##################################################

resource "azurerm_disk_encryption_set" "des" {

  for_each = local.environments

  name = each.key == "prod" ? (
    "des-qndis-jmp-prd-qc-001"
  ) : (
    "des-qndis-jmp-tst-qc-001"
  )

  location            = data.azurerm_resource_group.rg[each.key].location
  resource_group_name = data.azurerm_resource_group.rg[each.key].name

  key_vault_key_id = azurerm_key_vault_key.cmk[each.key].versionless_id

  encryption_type           = "EncryptionAtRestWithCustomerKey"
  auto_key_rotation_enabled = true

  identity {

    type = "UserAssigned"

    identity_ids = [
      azurerm_user_assigned_identity.uami[each.key].id
    ]
  }

  depends_on = [
    azurerm_role_assignment.crypto_user
  ]
}

##################################################
# Outputs
##################################################

output "key_vaults" {
  value = {
    for k, v in azurerm_key_vault.kv :
    k => v.name
  }
}

output "disk_encryption_sets" {
  value = {
    for k, v in azurerm_disk_encryption_set.des :
    k => v.name
  }
}