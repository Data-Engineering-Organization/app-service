output "app_url" {
  value       = "https://${module.app_service.default_hostname}"
  description = "HTTPS URL of the UAT app."
}

output "web_app_name" {
  value = module.app_service.web_app_name
}

output "resource_group_name" {
  value = azurerm_resource_group.app.name
}
