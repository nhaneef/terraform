variable "subscription_id" {
  type = string
}

variable "admin_username" {
  type    = string
  default = "qndislocaladmin"
}

variable "admin_password" {
  type      = string
  sensitive = true
}