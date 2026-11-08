output "traffic_manager_fqdn" {
  value       = module.app_service.traffic_manager_fqdn
  description = "Traffic Manager DNS name for UAT regional failover (DNS only; configure custom-domain TLS for HTTPS)."
}

output "web_app_name" {
  value = module.app_service.web_app_name
}

output "staging_hostname" {
  value = module.app_service.staging_hostname
}

output "secondary_web_app_name" {
  value = module.app_service.secondary_web_app_name
}

output "secondary_staging_hostname" {
  value = module.app_service.secondary_staging_hostname
}

output "health_check_path" {
  value = module.app_service.health_check_path
}

output "resource_group_name" {
  value = azurerm_resource_group.app.name
}
