output "storage_connection_string" {
  value = azurerm_storage_account.invoiceapi_storage.primary_connection_string
  sensitive = true
}

output "instrumentation_key" {
  value = azurerm_application_insights.invoiceapi.instrumentation_key
  sensitive = true
}

output "github_runner_client_id" {
  description = "Client ID for GitHub Runner managed identity"
  value       = azurerm_user_assigned_identity.github_runner_identity.client_id
}

output "github_runner_principal_id" {
  description = "Principal ID for GitHub Runner managed identity"
  value       = azurerm_user_assigned_identity.github_runner_identity.principal_id
}

output "subscription_id" {
  description = "Azure Subscription ID"
  value       = var.subscription_id
}

output "tenant_id" {
  description = "Azure Tenant ID"
  value       = data.azurerm_client_config.current.tenant_id
}

output "resource_group_name" {
  description = "Resource Group Name"
  value       = azurerm_resource_group.shared_rg.name
}

output "container_registry_login_server" {
  description = "Container Registry Login Server"
  value       = azurerm_container_registry.invoiceapi.login_server
}