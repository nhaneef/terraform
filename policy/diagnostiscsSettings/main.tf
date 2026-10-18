###############################################################################
# PROVIDER
###############################################################################

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

###############################################################################
# VARIABLES
###############################################################################

variable "management_group_id" {
  description = "Management Group Resource ID"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace Resource ID"
  type        = string
}

variable "location" {
  description = "Location required for managed identity"
  type        = string
  default     = "qatarcentral"
}

###############################################################################
# STORAGE ACCOUNT DIAGNOSTICS POLICY ASSIGNMENT
###############################################################################

resource "azurerm_management_group_policy_assignment" "storage_diagnostics" {
  name                 = "SA_Diagnostics"
  display_name         = "EMS-Configure Storage Account Diagnostics to Log Analytics"
  description          = "Deploy Diagnostic Settings for Storage Accounts to Log Analytics Workspace"
  management_group_id  = var.management_group_id

  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/59759c62-9a22-4cdf-ae64-074495983fef"

  location = var.location

  identity {
    type = "SystemAssigned"
  }

  parameters = jsonencode({
    effect = {
      value = "DeployIfNotExists"
    }

    logAnalytics = {
      value = var.log_analytics_workspace_id
    }

    metricsEnabled = {
      value = true
    }

    profileName = {
      value = "storageAccountsDiagnosticsLogsToSentinel"
    }
  })
}

###############################################################################
# ROLE ASSIGNMENTS
###############################################################################

# resource "azurerm_role_assignment" "monitoring_contributor" {
#   scope                = var.log_analytics_workspace_id
#   role_definition_name = "Monitoring Contributor"
#   principal_id         = azurerm_management_group_policy_assignment.storage_diagnostics.identity[0].principal_id
# }

# resource "azurerm_role_assignment" "log_analytics_contributor" {
#   scope                = var.log_analytics_workspace_id
#   role_definition_name = "Log Analytics Contributor"
#   principal_id         = azurerm_management_group_policy_assignment.storage_diagnostics.identity[0].principal_id
# }
# REQUIRED ROLE ASSIGNMENTS
###############################################################################

# Monitoring Contributor at Management Group scope
resource "azurerm_role_assignment" "monitoring_contributor" {
scope = var.management_group_id
role_definition_name = "Monitoring Contributor"
principal_id = azurerm_management_group_policy_assignment.storage_diagnostics.identity[0].principal_id
}

# Log Analytics Contributor on the target workspace
resource "azurerm_role_assignment" "log_analytics_contributor" {
scope = var.log_analytics_workspace_id
role_definition_name = "Log Analytics Contributor"
principal_id = azurerm_management_group_policy_assignment.storage_diagnostics.identity[0].principal_id
}
###############################################################################
# REMEDIATION TASK
###############################################################################

resource "azurerm_management_group_policy_remediation" "storage_diagnostics" {
  name                 = "storage-diagnostics-remediation"
  management_group_id  = var.management_group_id
  policy_assignment_id = azurerm_management_group_policy_assignment.storage_diagnostics.id

#   resource_discovery_mode = "ReEvaluateCompliance"

  depends_on = [
    azurerm_role_assignment.monitoring_contributor,
    azurerm_role_assignment.log_analytics_contributor
  ]
}