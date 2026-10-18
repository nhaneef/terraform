locals {

  role_definition_name = "Contributor"

}

resource "azurerm_subscription_policy_assignment" "required_tags" {

  for_each = var.subscription_tag_assignments

  name = lower(
    replace(
      "${each.value.subscription_name}-required-tags-policy",
      " ",
      "-"
    )
  )

  display_name = "${each.value.subscription_name}-Required Tags Policy"

  description = "Mandatory MoPH resource tags for ${each.value.subscription_name}"

  subscription_id      = "/subscriptions/${each.value.subscription_id}"
  policy_definition_id = var.policy_definition_id

  location = var.policy_assignment_location

  enforce = true

  identity {
    type = "SystemAssigned"
  }

  parameters = jsonencode({

    "Value-Project" = {
      value = each.value.project
    }

    "Value-Environment" = {
      value = each.value.environment
    }

    "Value-CostCenter" = {
      value = each.value.cost_center
    }

    "Value-ManagingVendor" = {
      value = each.value.managing_vendor
    }

    "Value-System" = {
      value = each.value.system
    }

    "Value-Approver" = {
      value = each.value.approver
    }

    "Value-BusinessUnit" = {
      value = each.value.business_unit
    }

  })

}

resource "azurerm_role_assignment" "policy_msi_contributor" {

  for_each = var.subscription_tag_assignments

  scope = "/subscriptions/${each.value.subscription_id}"

  role_definition_name = "Contributor"

  principal_id = azurerm_subscription_policy_assignment.required_tags[each.key].identity[0].principal_id

  principal_type = "ServicePrincipal"

  skip_service_principal_aad_check = true
}

resource "azurerm_subscription_policy_remediation" "required_tags" {

  for_each = var.subscription_tag_assignments

  name = "remediate-required-tags"

  subscription_id      = "/subscriptions/${each.value.subscription_id}"
  policy_assignment_id = azurerm_subscription_policy_assignment.required_tags[each.key].id

  resource_discovery_mode = "ReEvaluateCompliance"

  depends_on = [
    azurerm_role_assignment.policy_msi_contributor
  ]
}