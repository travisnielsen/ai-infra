output "storage_connection_string" {
  value = azurerm_storage_account.invoiceapi_storage.primary_connection_string
  sensitive = true
}

output "instrumentation_key" {
  value = azurerm_application_insights.invoiceapi.instrumentation_key
  sensitive = true
}