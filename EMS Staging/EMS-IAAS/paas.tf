data "azurerm_virtual_network" "ems-onpvnet"{
name = var.vnet_name
resource_group_name = var.rg_network
}

data "azurerm_subnet" "paas" {
  name                 = "snet-ems-onprem-paas-stg-qc-001"
  virtual_network_name = "vnet-ems-onprem-network-stg-qc-001"
  resource_group_name  = "rg-ems-onprem-network-stg-qc-001"
}

