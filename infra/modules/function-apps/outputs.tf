# Function Apps Module Outputs

output "service_plan_ids" {
  description = "IDs of the service plans"
  value = merge(
    { for name, plan in azurerm_service_plan.function_plans : name => plan.id },
    var.consumption_plan_enabled ? { "consumption" = azurerm_service_plan.consumption[0].id } : {}
  )
}

output "linux_function_apps" {
  description = "Information about Linux function apps"
  value = {
    for name, app in azurerm_linux_function_app.linux_apps : name => {
      id                    = app.id
      name                  = app.name
      default_hostname      = app.default_hostname
      principal_id          = app.identity[0].principal_id
      outbound_ip_addresses = app.outbound_ip_addresses
    }
  }
}

output "windows_function_apps" {
  description = "Information about Windows function apps"
  value = {
    for name, app in azurerm_windows_function_app.windows_apps : name => {
      id                    = app.id
      name                  = app.name
      default_hostname      = app.default_hostname
      principal_id          = app.identity[0].principal_id
      outbound_ip_addresses = app.outbound_ip_addresses
    }
  }
}

output "function_app_urls" {
  description = "URLs of all function apps"
  value = merge(
    {
      for name, app in azurerm_linux_function_app.linux_apps :
      name => "https://${app.default_hostname}"
    },
    {
      for name, app in azurerm_windows_function_app.windows_apps :
      name => "https://${app.default_hostname}"
    }
  )
}

output "function_app_identities" {
  description = "Managed identities of function apps"
  value = merge(
    {
      for name, app in azurerm_linux_function_app.linux_apps :
      name => app.identity[0].principal_id
    },
    {
      for name, app in azurerm_windows_function_app.windows_apps :
      name => app.identity[0].principal_id
    }
  )
}