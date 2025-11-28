# Service Plans for Function Apps
resource "azurerm_service_plan" "function_plans" {
  for_each = {
    for app in var.function_apps : app.name => app
    if !var.consumption_plan_enabled
  }

  name                = "${var.project_name}-${each.value.name}-plan-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = title(each.value.os_type)
  sku_name            = each.value.service_plan_sku

  tags = merge(var.tags, {
    Module = "function-apps"
    App    = each.value.name
  })
}

# Consumption Plan (Serverless)
resource "azurerm_service_plan" "consumption" {
  count = var.consumption_plan_enabled ? 1 : 0

  name                = "${var.project_name}-consumption-plan-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "Y1"

  tags = merge(var.tags, {
    Module = "function-apps"
    Type   = "consumption"
  })
}

# Function Apps
resource "azurerm_linux_function_app" "linux_apps" {
  for_each = {
    for app in var.function_apps : app.name => app
    if app.os_type == "linux"
  }

  name                = "${var.project_name}-${each.value.name}-func-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location

  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key
  service_plan_id           = var.consumption_plan_enabled ? azurerm_service_plan.consumption[0].id : azurerm_service_plan.function_plans[each.key].id

  # Identity configuration
  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }

  # Site configuration
  site_config {
    always_on = each.value.always_on && !var.consumption_plan_enabled

    application_stack {
      python_version = each.value.runtime_stack == "python" ? each.value.runtime_version : null
      node_version   = each.value.runtime_stack == "node" ? each.value.runtime_version : null
      dotnet_version = each.value.runtime_stack == "dotnet" ? each.value.runtime_version : null
      java_version   = each.value.runtime_stack == "java" ? each.value.runtime_version : null
    }

    # CORS configuration
    cors {
      allowed_origins     = ["*"]
      support_credentials = false
    }

    # Application Insights
    application_insights_key               = var.application_insights_key
    application_insights_connection_string = var.application_insights_connection_string
  }

  # App settings
  app_settings = merge(
    {
      "FUNCTIONS_EXTENSION_VERSION"              = "~4"
      "FUNCTIONS_WORKER_RUNTIME"                 = each.value.runtime_stack
      "WEBSITE_RUN_FROM_PACKAGE"                 = "1"
      "APPINSIGHTS_INSTRUMENTATIONKEY"           = var.application_insights_key
      "APPLICATIONINSIGHTS_CONNECTION_STRING"    = var.application_insights_connection_string
      "AzureWebJobsStorage"                      = "DefaultEndpointsProtocol=https;AccountName=${var.storage_account_name};AccountKey=${var.storage_account_access_key};EndpointSuffix=core.windows.net"
    },
    each.value.app_settings
  )

  # Connection strings
  dynamic "connection_string" {
    for_each = each.value.connection_strings
    content {
      name  = connection_string.key
      type  = "Custom"
      value = connection_string.value
    }
  }

  tags = merge(var.tags, {
    Module  = "function-apps"
    App     = each.value.name
    Runtime = each.value.runtime_stack
  })
}

# Windows Function Apps
resource "azurerm_windows_function_app" "windows_apps" {
  for_each = {
    for app in var.function_apps : app.name => app
    if app.os_type == "windows"
  }

  name                = "${var.project_name}-${each.value.name}-func-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location

  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key
  service_plan_id           = var.consumption_plan_enabled ? azurerm_service_plan.consumption[0].id : azurerm_service_plan.function_plans[each.key].id

  # Identity configuration
  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }

  # Site configuration
  site_config {
    always_on = each.value.always_on && !var.consumption_plan_enabled

    application_stack {
      node_version    = each.value.runtime_stack == "node" ? each.value.runtime_version : null
      dotnet_version  = each.value.runtime_stack == "dotnet" ? each.value.runtime_version : null
      java_version    = each.value.runtime_stack == "java" ? each.value.runtime_version : null
      powershell_core_version = each.value.runtime_stack == "powershell" ? each.value.runtime_version : null
    }

    # CORS configuration
    cors {
      allowed_origins     = ["*"]
      support_credentials = false
    }

    # Application Insights
    application_insights_key               = var.application_insights_key
    application_insights_connection_string = var.application_insights_connection_string
  }

  # App settings
  app_settings = merge(
    {
      "FUNCTIONS_EXTENSION_VERSION"              = "~4"
      "FUNCTIONS_WORKER_RUNTIME"                 = each.value.runtime_stack
      "WEBSITE_RUN_FROM_PACKAGE"                 = "1"
      "APPINSIGHTS_INSTRUMENTATIONKEY"           = var.application_insights_key
      "APPLICATIONINSIGHTS_CONNECTION_STRING"    = var.application_insights_connection_string
      "AzureWebJobsStorage"                      = "DefaultEndpointsProtocol=https;AccountName=${var.storage_account_name};AccountKey=${var.storage_account_access_key};EndpointSuffix=core.windows.net"
    },
    each.value.app_settings
  )

  # Connection strings
  dynamic "connection_string" {
    for_each = each.value.connection_strings
    content {
      name  = connection_string.key
      type  = "Custom"
      value = connection_string.value
    }
  }

  tags = merge(var.tags, {
    Module  = "function-apps"
    App     = each.value.name
    Runtime = each.value.runtime_stack
  })
}

# VNet Integration for Function Apps
resource "azurerm_app_service_virtual_network_swift_connection" "linux_vnet" {
  for_each = {
    for app in var.function_apps : app.name => app
    if app.os_type == "linux" && app.enable_vnet_integration && var.subnet_id != ""
  }

  app_service_id = azurerm_linux_function_app.linux_apps[each.key].id
  subnet_id      = var.subnet_id
}

resource "azurerm_app_service_virtual_network_swift_connection" "windows_vnet" {
  for_each = {
    for app in var.function_apps : app.name => app
    if app.os_type == "windows" && app.enable_vnet_integration && var.subnet_id != ""
  }

  app_service_id = azurerm_windows_function_app.windows_apps[each.key].id
  subnet_id      = var.subnet_id
}