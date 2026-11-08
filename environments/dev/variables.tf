variable "name_prefix" {
  description = "Short globally unique prefix for resource names."
  type        = string
  default     = "myapp"
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "Central India"
}

variable "sku_name" {
  description = "App Service Plan SKU."
  type        = string
  default     = "B1"
}

variable "always_on" {
  type    = bool
  default = true
}

variable "app_settings" {
  description = "Non-secret app settings."
  type        = map(string)
  default     = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
