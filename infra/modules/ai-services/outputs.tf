# AI Services Module Outputs

output "openai_service" {
  description = "Azure OpenAI service information"
  value = length(azurerm_cognitive_account.openai) > 0 ? {
    id       = azurerm_cognitive_account.openai[0].id
    name     = azurerm_cognitive_account.openai[0].name
    endpoint = azurerm_cognitive_account.openai[0].endpoint
    key      = azurerm_cognitive_account.openai[0].primary_access_key
  } : null
  sensitive = true
}

output "openai_deployments" {
  description = "OpenAI model deployments"
  value = {
    for name, deployment in azurerm_cognitive_deployment.openai_deployments : name => {
      id    = deployment.id
      name  = deployment.name
      model = deployment.model[0].name
    }
  }
}

output "form_recognizer_service" {
  description = "Azure Form Recognizer service information"
  value = length(azurerm_cognitive_account.form_recognizer) > 0 ? {
    id       = azurerm_cognitive_account.form_recognizer[0].id
    name     = azurerm_cognitive_account.form_recognizer[0].name
    endpoint = azurerm_cognitive_account.form_recognizer[0].endpoint
    key      = azurerm_cognitive_account.form_recognizer[0].primary_access_key
  } : null
  sensitive = true
}

output "computer_vision_service" {
  description = "Azure Computer Vision service information"
  value = length(azurerm_cognitive_account.computer_vision) > 0 ? {
    id       = azurerm_cognitive_account.computer_vision[0].id
    name     = azurerm_cognitive_account.computer_vision[0].name
    endpoint = azurerm_cognitive_account.computer_vision[0].endpoint
    key      = azurerm_cognitive_account.computer_vision[0].primary_access_key
  } : null
  sensitive = true
}

output "cognitive_services" {
  description = "Additional cognitive services information"
  value = {
    for name, service in azurerm_cognitive_account.services : name => {
      id       = service.id
      name     = service.name
      kind     = service.kind
      endpoint = service.endpoint
      key      = service.primary_access_key
    }
  }
  sensitive = true
}

output "service_endpoints" {
  description = "All AI service endpoints"
  value = merge(
    length(azurerm_cognitive_account.openai) > 0 ? {
      openai = azurerm_cognitive_account.openai[0].endpoint
    } : {},
    length(azurerm_cognitive_account.form_recognizer) > 0 ? {
      form_recognizer = azurerm_cognitive_account.form_recognizer[0].endpoint
    } : {},
    length(azurerm_cognitive_account.computer_vision) > 0 ? {
      computer_vision = azurerm_cognitive_account.computer_vision[0].endpoint
    } : {},
    {
      for name, service in azurerm_cognitive_account.services : name => service.endpoint
    }
  )
}

output "key_vault_secret_names" {
  description = "Names of secrets stored in Key Vault"
  value = concat(
    length(azurerm_key_vault_secret.openai_key) > 0 ? [azurerm_key_vault_secret.openai_key[0].name] : [],
    length(azurerm_key_vault_secret.openai_endpoint) > 0 ? [azurerm_key_vault_secret.openai_endpoint[0].name] : [],
    length(azurerm_key_vault_secret.form_recognizer_key) > 0 ? [azurerm_key_vault_secret.form_recognizer_key[0].name] : [],
    length(azurerm_key_vault_secret.form_recognizer_endpoint) > 0 ? [azurerm_key_vault_secret.form_recognizer_endpoint[0].name] : []
  )
}