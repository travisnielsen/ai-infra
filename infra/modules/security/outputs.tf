output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.invoicekv.id
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.invoicekv.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.invoicekv.vault_uri
}

output "managed_identity_ids" {
  description = "Map of managed identity names to IDs"
  value       = { for k, v in azurerm_user_assigned_identity.identities : k => v.id }
}

output "managed_identity_principal_ids" {
  description = "Map of managed identity names to principal IDs"
  value       = { for k, v in azurerm_user_assigned_identity.identities : k => v.principal_id }
}

output "managed_identity_client_ids" {
  description = "Map of managed identity names to client IDs"
  value       = { for k, v in azurerm_user_assigned_identity.identities : k => v.client_id }
}