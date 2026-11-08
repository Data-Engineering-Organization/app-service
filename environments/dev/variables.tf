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

variable "secondary_location" {
  description = "Paired region used for disaster recovery."
  type        = string
  default     = "South India"
}

variable "sku_name" {
  description = "App Service Plan SKU."
  type        = string
  default     = "S1"
}

variable "health_check_path" {
  description = "The application must return HTTP 200 at this path."
  type        = string
  default     = "/health"
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
