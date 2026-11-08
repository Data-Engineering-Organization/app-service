variable "resource_group_name" {
  description = "Resource group for the remote state storage account."
  type        = string
  default     = "terraform-state-rg"
}

variable "location" {
  description = "Azure region for state storage."
  type        = string
  default     = "Central India"
}

variable "storage_account_prefix" {
  description = "Globally unique lowercase alphanumeric prefix, up to 18 characters."
  type        = string
  default     = "tfstate"
}

variable "account_replication_type" {
  description = "Storage redundancy type for remote Terraform state. GRS replicates to the paired region."
  type        = string
  default     = "GRS"
}

output "resource_group_name" {
  value = azurerm_resource_group.state.name
}

output "storage_account_name" {
  value = azurerm_storage_account.state.name
}

output "container_name" {
  value = azurerm_storage_container.state.name
}
