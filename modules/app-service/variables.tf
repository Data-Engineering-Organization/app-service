variable "name_prefix" {
  description = "Globally unique prefix used for App Service resources."
  type        = string
}

variable "location" {
  description = "Azure region for the resources."
  type        = string
}

variable "secondary_location" {
  description = "Paired Azure region hosting the disaster-recovery app."
  type        = string
  default     = "South India"
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
  description = "App Service Plan SKU. Standard or higher is required for deployment slots."
  type        = string
  default     = "S1"
}

variable "health_check_path" {
  description = "Application endpoint used by App Service, deployment validation, and Traffic Manager health probes. The app must return HTTP 200 here."
  type        = string
  default     = "/health"
}

variable "always_on" {
  description = "Keep the app loaded. Requires an eligible non-Free plan."
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
