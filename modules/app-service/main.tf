resource "azurerm_service_plan" "this" {
  name                = "${var.name_prefix}-${var.environment}-plan"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.sku_name
  tags                = var.tags
}

resource "azurerm_linux_web_app" "this" {
  name                = "${var.name_prefix}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.this.id
  https_only          = var.https_only
  tags                = var.tags

  site_config {
    always_on           = var.always_on
    minimum_tls_version = "1.2"
    http2_enabled       = true
    ftps_state          = "Disabled"
  }

  app_settings = merge(
    {
      "WEBSITE_RUN_FROM_PACKAGE" = "1"
    },
    var.app_settings
  )
}
