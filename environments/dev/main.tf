terraform {
  backend "azurerm" {
    resource_group_name  = "tfstateRG01"
    storage_account_name = "tfstate01965229201"
    container_name       = "tfstate"
    key                  = "dev.tfstate"
    use_cli              = true
    use_azuread_auth     = true
  }
}

module "app_service" {
  source = "../../modules/app-service"

  name_prefix         = var.name_prefix
  environment         = "dev"
  location            = var.location
  secondary_location  = var.secondary_location
  resource_group_name = azurerm_resource_group.app.name
  sku_name            = var.sku_name
  always_on           = var.always_on
  health_check_path   = var.health_check_path
  app_settings        = var.app_settings
  tags                = local.tags
}

resource "azurerm_resource_group" "app" {
  name     = "${var.name_prefix}-dev-rg"
  location = var.location
  tags     = local.tags
}

locals {
  tags = merge(var.tags, { environment = "dev", managed_by = "terraform" })
}
