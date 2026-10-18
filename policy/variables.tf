variable "policy_definition_id" {
  description = "MOPH Required Tags Policy Definition ID"
  type        = string
}

variable "policy_assignment_location" {
  description = "Location for Policy Assignment Managed Identity"
  type        = string
  default     = "qatarcentral"
}

variable "subscription_tag_assignments" {

  type = map(object({
    subscription_name = string
    subscription_id   = string

    project           = string
    environment       = string
    cost_center       = string
    managing_vendor   = string
    system            = string
    approver          = string
    business_unit     = string
  }))
}