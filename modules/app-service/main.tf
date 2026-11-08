locals {
  web_app_settings = merge(
    {
      "WEBSITE_RUN_FROM_PACKAGE"          = "1"
      "WEBSITE_SWAP_WARMUP_PING_PATH"     = var.health_check_path
      "WEBSITE_SWAP_WARMUP_PING_STATUSES" = "200"
    },
    var.app_settings
  )

  tags = merge(var.tags, {
    environment = var.environment
    managed_by  = "terraform"
  })
}

resource "azurerm_service_plan" "primary" {
  name                = "${var.name_prefix}-${var.environment}-plan"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.sku_name
  tags                = merge(local.tags, { region_role = "primary" })
}

resource "azurerm_linux_web_app" "primary" {
  name                = "${var.name_prefix}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.primary.id
  https_only          = true
  tags                = merge(local.tags, { region_role = "primary" })

  site_config {
    always_on                         = var.always_on
    minimum_tls_version               = "1.2"
    http2_enabled                     = true
    ftps_state                        = "Disabled"
    health_check_path                 = var.health_check_path
    health_check_eviction_time_in_min = 5
  }

  sticky_settings {
    app_setting_names = keys(local.web_app_settings)
  }

  app_settings = local.web_app_settings
}

resource "azurerm_linux_web_app_slot" "primary_staging" {
  name           = "staging"
  app_service_id = azurerm_linux_web_app.primary.id
  https_only     = true
  tags           = merge(local.tags, { region_role = "primary" })

  site_config {
    always_on                         = var.always_on
    minimum_tls_version               = "1.2"
    http2_enabled                     = true
    ftps_state                        = "Disabled"
    health_check_path                 = var.health_check_path
    health_check_eviction_time_in_min = 5
  }

  app_settings = local.web_app_settings
}

resource "azurerm_service_plan" "secondary" {
  name                = "${var.name_prefix}-${var.environment}-dr-plan"
  resource_group_name = var.resource_group_name
  location            = var.secondary_location
  os_type             = "Linux"
  sku_name            = var.sku_name
  tags                = merge(local.tags, { region_role = "secondary" })
}

resource "azurerm_linux_web_app" "secondary" {
  name                = "${var.name_prefix}-${var.environment}-dr"
  resource_group_name = var.resource_group_name
  location            = var.secondary_location
  service_plan_id     = azurerm_service_plan.secondary.id
  https_only          = true
  tags                = merge(local.tags, { region_role = "secondary" })

  site_config {
    always_on                         = var.always_on
    minimum_tls_version               = "1.2"
    http2_enabled                     = true
    ftps_state                        = "Disabled"
    health_check_path                 = var.health_check_path
    health_check_eviction_time_in_min = 5
  }

  sticky_settings {
    app_setting_names = keys(local.web_app_settings)
  }

  app_settings = local.web_app_settings
}

resource "azurerm_linux_web_app_slot" "secondary_staging" {
  name           = "staging"
  app_service_id = azurerm_linux_web_app.secondary.id
  https_only     = true
  tags           = merge(local.tags, { region_role = "secondary" })

  site_config {
    always_on                         = var.always_on
    minimum_tls_version               = "1.2"
    http2_enabled                     = true
    ftps_state                        = "Disabled"
    health_check_path                 = var.health_check_path
    health_check_eviction_time_in_min = 5
  }

  app_settings = local.web_app_settings
}

resource "azurerm_traffic_manager_profile" "this" {
  name                   = "tm-${var.name_prefix}-${var.environment}"
  resource_group_name    = var.resource_group_name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "tm-${var.name_prefix}-${var.environment}"
    ttl           = 30
  }

  monitor_config {
    protocol                     = "HTTPS"
    port                         = 443
    path                         = var.health_check_path
    interval_in_seconds          = 30
    timeout_in_seconds           = 10
    tolerated_number_of_failures = 3
  }

  tags = local.tags
}

resource "azurerm_traffic_manager_azure_endpoint" "primary" {
  name               = "primary"
  profile_id         = azurerm_traffic_manager_profile.this.id
  target_resource_id = azurerm_linux_web_app.primary.id
  priority           = 1
}

resource "azurerm_traffic_manager_azure_endpoint" "secondary" {
  name               = "secondary"
  profile_id         = azurerm_traffic_manager_profile.this.id
  target_resource_id = azurerm_linux_web_app.secondary.id
  priority           = 2
}
