# Azure OpenAI Service
resource "azurerm_cognitive_account" "openai" {
  count               = length([for service in var.cognitive_services : service if service.kind == "OpenAI"]) > 0 ? 1 : 0
  name                = "${var.project_name}-openai-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "OpenAI"
  sku_name            = "S0"

  custom_subdomain_name = "${var.project_name}-openai-${var.environment}"

  # Network restrictions
  network_acls {
    default_action = var.network_restrictions.default_action
    
    dynamic "ip_rules" {
      for_each = var.network_restrictions.ip_rules
      content {
        ip_range = ip_rules.value
      }
    }

    dynamic "virtual_network_rules" {
      for_each = var.network_restrictions.virtual_network_rules
      content {
        subnet_id = virtual_network_rules.value.subnet_id
      }
    }
  }

  # Identity
  identity {
    type = "SystemAssigned"
  }

  tags = merge(var.tags, {
    Module  = "ai-services"
    Service = "OpenAI"
  })
}

# OpenAI Model Deployments
resource "azurerm_cognitive_deployment" "openai_deployments" {
  for_each = {
    for deployment in var.openai_deployments : deployment.name => deployment
    if length([for service in var.cognitive_services : service if service.kind == "OpenAI"]) > 0
  }

  name                 = each.value.name
  cognitive_account_id = azurerm_cognitive_account.openai[0].id

  model {
    format  = "OpenAI"
    name    = each.value.model
    version = each.value.version
  }

  sku {
    name     = "Standard"
    capacity = each.value.capacity
  }
}

# Azure Form Recognizer (Document Intelligence)
resource "azurerm_cognitive_account" "form_recognizer" {
  count               = var.form_recognizer_enabled ? 1 : 0
  name                = "${var.project_name}-docint-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "FormRecognizer"
  sku_name            = "S0"

  custom_subdomain_name = "${var.project_name}-docint-${var.environment}"

  # Network restrictions
  network_acls {
    default_action = var.network_restrictions.default_action
    
    dynamic "ip_rules" {
      for_each = var.network_restrictions.ip_rules
      content {
        ip_range = ip_rules.value
      }
    }

    dynamic "virtual_network_rules" {
      for_each = var.network_restrictions.virtual_network_rules
      content {
        subnet_id = virtual_network_rules.value.subnet_id
      }
    }
  }

  # Identity
  identity {
    type = "SystemAssigned"
  }

  tags = merge(var.tags, {
    Module  = "ai-services"
    Service = "FormRecognizer"
  })
}

# Azure Computer Vision
resource "azurerm_cognitive_account" "computer_vision" {
  count               = var.computer_vision_enabled ? 1 : 0
  name                = "${var.project_name}-vision-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "ComputerVision"
  sku_name            = "S1"

  # Network restrictions
  network_acls {
    default_action = var.network_restrictions.default_action
    
    dynamic "ip_rules" {
      for_each = var.network_restrictions.ip_rules
      content {
        ip_range = ip_rules.value
      }
    }

    dynamic "virtual_network_rules" {
      for_each = var.network_restrictions.virtual_network_rules
      content {
        subnet_id = virtual_network_rules.value.subnet_id
      }
    }
  }

  # Identity
  identity {
    type = "SystemAssigned"
  }

  tags = merge(var.tags, {
    Module  = "ai-services"
    Service = "ComputerVision"
  })
}

# Additional Cognitive Services
resource "azurerm_cognitive_account" "services" {
  for_each = {
    for service in var.cognitive_services : service.name => service
    if service.kind != "OpenAI" # OpenAI is handled separately
  }

  name                = "${var.project_name}-${each.value.name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = each.value.kind
  sku_name            = each.value.sku_name

  custom_subdomain_name = each.value.custom_subdomain ? "${var.project_name}-${each.value.name}-${var.environment}" : null

  # Network restrictions
  network_acls {
    default_action = var.network_restrictions.default_action
    
    dynamic "ip_rules" {
      for_each = var.network_restrictions.ip_rules
      content {
        ip_range = ip_rules.value
      }
    }

    dynamic "virtual_network_rules" {
      for_each = var.network_restrictions.virtual_network_rules
      content {
        subnet_id = virtual_network_rules.value.subnet_id
      }
    }
  }

  # Identity
  identity {
    type = "SystemAssigned"
  }

  tags = merge(var.tags, {
    Module  = "ai-services"
    Service = each.value.kind
  })
}

# Model Deployments for Additional Services
resource "azurerm_cognitive_deployment" "service_deployments" {
  for_each = {
    for idx, deployment in flatten([
      for service in var.cognitive_services : [
        for deployment in service.deployments : {
          key         = "${service.name}-${deployment.name}"
          service_key = service.name
          deployment  = deployment
        }
      ]
    ]) : deployment.key => deployment
    if contains(keys(azurerm_cognitive_account.services), deployment.service_key)
  }

  name                 = each.value.deployment.name
  cognitive_account_id = azurerm_cognitive_account.services[each.value.service_key].id

  model {
    format  = each.value.deployment.model.format
    name    = each.value.deployment.model.name
    version = each.value.deployment.model.version
  }

  sku {
    name     = each.value.deployment.scale.type
    capacity = each.value.deployment.scale.capacity
  }
}

# Store API keys in Key Vault
resource "azurerm_key_vault_secret" "openai_key" {
  count        = length(azurerm_cognitive_account.openai) > 0 ? 1 : 0
  name         = "openai-api-key"
  value        = azurerm_cognitive_account.openai[0].primary_access_key
  key_vault_id = var.key_vault_id

  tags = merge(var.tags, {
    Module = "ai-services"
  })
}

resource "azurerm_key_vault_secret" "openai_endpoint" {
  count        = length(azurerm_cognitive_account.openai) > 0 ? 1 : 0
  name         = "openai-endpoint"
  value        = azurerm_cognitive_account.openai[0].endpoint
  key_vault_id = var.key_vault_id

  tags = merge(var.tags, {
    Module = "ai-services"
  })
}

resource "azurerm_key_vault_secret" "form_recognizer_key" {
  count        = length(azurerm_cognitive_account.form_recognizer) > 0 ? 1 : 0
  name         = "form-recognizer-api-key"
  value        = azurerm_cognitive_account.form_recognizer[0].primary_access_key
  key_vault_id = var.key_vault_id

  tags = merge(var.tags, {
    Module = "ai-services"
  })
}

resource "azurerm_key_vault_secret" "form_recognizer_endpoint" {
  count        = length(azurerm_cognitive_account.form_recognizer) > 0 ? 1 : 0
  name         = "form-recognizer-endpoint"
  value        = azurerm_cognitive_account.form_recognizer[0].endpoint
  key_vault_id = var.key_vault_id

  tags = merge(var.tags, {
    Module = "ai-services"
  })
}

# Private Endpoints (if enabled)
resource "azurerm_private_endpoint" "openai" {
  count               = var.private_endpoints_enabled && length(azurerm_cognitive_account.openai) > 0 ? 1 : 0
  name                = "${azurerm_cognitive_account.openai[0].name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${azurerm_cognitive_account.openai[0].name}-psc"
    private_connection_resource_id = azurerm_cognitive_account.openai[0].id
    subresource_names              = ["account"]
    is_manual_connection           = false
  }

  tags = merge(var.tags, {
    Module = "ai-services"
  })
}