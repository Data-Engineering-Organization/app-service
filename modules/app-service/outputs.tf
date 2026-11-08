output "web_app_name" {
  description = "Primary region Linux Web App name."
  value       = azurerm_linux_web_app.primary.name
}

output "default_hostname" {
  description = "Primary region Web App hostname."
  value       = azurerm_linux_web_app.primary.default_hostname
}

output "web_app_id" {
  description = "Primary region Web App resource ID."
  value       = azurerm_linux_web_app.primary.id
}

output "service_plan_id" {
  description = "Primary region App Service Plan resource ID."
  value       = azurerm_service_plan.primary.id
}

output "staging_hostname" {
  description = "Primary region staging slot hostname."
  value       = azurerm_linux_web_app_slot.primary_staging.default_hostname
}

output "secondary_web_app_name" {
  description = "Secondary region Linux Web App name."
  value       = azurerm_linux_web_app.secondary.name
}

output "secondary_default_hostname" {
  description = "Secondary region Web App hostname."
  value       = azurerm_linux_web_app.secondary.default_hostname
}

output "secondary_staging_hostname" {
  description = "Secondary region staging slot hostname."
  value       = azurerm_linux_web_app_slot.secondary_staging.default_hostname
}

output "traffic_manager_fqdn" {
  description = "Traffic Manager DNS name for priority-based regional failover. Add a custom domain and bind TLS certificates on both apps before using it as an HTTPS URL."
  value       = azurerm_traffic_manager_profile.this.fqdn
}

output "health_check_path" {
  description = "Health endpoint used for slot validation and regional failover."
  value       = var.health_check_path
}
