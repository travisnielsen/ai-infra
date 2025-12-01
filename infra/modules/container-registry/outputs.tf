output "name" {
  description = "Name of the Container Registry"
  value       = azurerm_container_registry.registry.name
}

output "id" {
  description = "ID of the Container Registry"
  value       = azurerm_container_registry.registry.id
}

output "login_server" {
  description = "Login server of the Container Registry"
  value       = azurerm_container_registry.registry.login_server
}