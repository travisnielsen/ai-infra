# Container Apps Environment
resource "azurerm_container_app_environment" "main" {
  name                       = "${var.project_name}-${var.environment}-cae"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # Network configuration
  infrastructure_subnet_id          = var.subnet_id
  internal_load_balancer_enabled    = false

  # Dapr configuration
  dapr_application_insights_connection_string = null
  
  tags = merge(var.tags, {
    Module = "container-apps"
  })
}

# Container Registry Secret
resource "azurerm_container_app_environment_storage" "registry" {
  count                        = var.container_registry_id != "" ? 1 : 0
  name                         = "registry-storage"
  container_app_environment_id = azurerm_container_app_environment.main.id
  account_name                 = split("/", var.container_registry_id)[8] # Extract ACR name
  share_name                   = "registry"
  access_key                   = "" # Will be managed through managed identity
  access_mode                  = "ReadOnly"
}

# Container Apps
resource "azurerm_container_app" "apps" {
  for_each = {
    for app in var.container_apps : app.name => app
  }

  name                         = "${var.project_name}-${each.value.name}-${var.environment}"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  # Identity configuration
  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }

  # Registry configuration
  dynamic "registry" {
    for_each = var.container_registry_server != "" ? [1] : []
    content {
      server   = var.container_registry_server
      identity = var.managed_identity_id
    }
  }

  # Template configuration
  template {
    min_replicas = each.value.min_replicas
    max_replicas = each.value.max_replicas

    container {
      name   = each.value.name
      image  = each.value.image
      cpu    = each.value.cpu
      memory = each.value.memory

      # Environment variables
      dynamic "env" {
        for_each = each.value.env_vars
        content {
          name  = env.value.name
          value = env.value.value
        }
      }

      # Secrets as environment variables
      dynamic "env" {
        for_each = each.value.secrets
        content {
          name        = env.value.name
          secret_name = env.value.name
        }
      }
    }
  }

  # Secrets
  dynamic "secret" {
    for_each = each.value.secrets
    content {
      name  = secret.value.name
      value = secret.value.value
    }
  }

  # Ingress configuration
  dynamic "ingress" {
    for_each = each.value.external_ingress ? [1] : []
    content {
      allow_insecure_connections = false
      external_enabled           = true
      target_port                = each.value.target_port

      traffic_weight {
        percentage      = 100
        latest_revision = true
      }
    }
  }

  tags = merge(var.tags, {
    Module = "container-apps"
    App    = each.value.name
  })
}

# Container App Jobs (for batch processing)
resource "azurerm_container_app_job" "jobs" {
  for_each = {} # Define jobs if needed

  name                         = "${var.project_name}-${each.key}-job-${var.environment}"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  container_app_environment_id = azurerm_container_app_environment.main.id

  replica_timeout_in_seconds = 1800
  replica_retry_limit        = 3

  template {
    container {
      image  = each.value.image
      name   = each.key
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  tags = merge(var.tags, {
    Module = "container-apps"
    Type   = "job"
  })
}