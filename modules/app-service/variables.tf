variable "name_prefix" {
  description = "Globally unique prefix used for App Service resources."
  type        = string
}

variable "location" {
  description = "Azure region for the resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group that contains the app and its plan."
  type        = string
}

variable "sku_name" {
  description = "App Service Plan SKU, for example B1 or P1v3."
  type        = string
  default     = "B1"
}

variable "always_on" {
  description = "Keep the app loaded. Requires an eligible non-Free plan."
  type        = bool
  default     = true
}

variable "https_only" {
  description = "Require HTTPS for incoming requests."
  type        = bool
  default     = true
}

variable "app_settings" {
  description = "Additional application settings. Do not put secrets in Terraform state."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags applied to Azure resources."
  type        = map(string)
  default     = {}
}
