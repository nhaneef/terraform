
variable "location" {
  type    = string
  default = "qatarcentral"
}


resource "azurerm_resource_group" "paas_rg" {
  name     = "rg-ems-onprem-paas-stg-qc-001"
  location = var.location
}

data "azurerm_client_config" "current" {}
# Premium Key Vault
resource "azurerm_key_vault" "kv_premium" {
  name                = "kv-emsonp-cmk-stg-qc-001"
  location            = azurerm_resource_group.paas_rg.location
  resource_group_name = azurerm_resource_group.paas_rg.name
   tenant_id          = data.azurerm_client_config.current.tenant_id

  sku_name = "premium"

  purge_protection_enabled      = true
  soft_delete_retention_days    = 90
  public_network_access_enabled = false
  rbac_authorization_enabled     = true
}

# Standard Key Vault
resource "azurerm_key_vault" "kv_standard" {
  name                = "kv-emsonp-sec-stg-qc-001"
  location            = azurerm_resource_group.paas_rg.location
  resource_group_name = azurerm_resource_group.paas_rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  purge_protection_enabled      = true
  soft_delete_retention_days    = 90
  public_network_access_enabled = false
  rbac_authorization_enabled     = true
}