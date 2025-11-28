# main.tf - Modular Infrastructure Configuration

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.0"
    }
  }
}

# Data sources
data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

data "external" "me" {
  program = ["az", "account", "show", "--query", "user"]
}

# Local values
locals {
  identifier = random_string.naming.result
  prefix     = random_string.naming.result
  tags = {
    Environment     = "Demo"
    Owner          = lookup(data.external.me.result, "name")
    SecurityControl = "Ignore"
    ManagedBy      = "Terraform"
  }
}

# Random naming
resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

# Resource Group
resource "azurerm_resource_group" "shared_rg" {
  name     = local.prefix
  location = var.region
  tags     = local.tags
}

# Networking Module
module "networking" {
  source = "./modules/networking"

  prefix              = local.prefix
  resource_group_name = azurerm_resource_group.shared_rg.name
  location            = azurerm_resource_group.shared_rg.location
  cidr                = var.cidr
  tags                = local.tags
}

# Observability Module
module "observability" {
  source = "./modules/observability"

  prefix              = local.prefix
  resource_group_name = azurerm_resource_group.shared_rg.name
  location            = azurerm_resource_group.shared_rg.location
  tags                = local.tags
}

# Security Module
module "security" {
  source = "./modules/security"

  prefix                 = local.prefix
  resource_group_name    = azurerm_resource_group.shared_rg.name
  location               = azurerm_resource_group.shared_rg.location
  tenant_id              = data.azurerm_client_config.current.tenant_id
  current_user_object_id = data.azurerm_client_config.current.object_id
  subnet_id              = module.networking.subnet_ids.services
  private_dns_zone_id    = module.networking.private_dns_zone_ids.keyvault
  tags                   = local.tags
}

# GitHub Runner Module
module "github_runner" {
  source = "./modules/github-runner"

  prefix                        = local.prefix
  resource_group_name           = azurerm_resource_group.shared_rg.name
  location                      = azurerm_resource_group.shared_rg.location
  subnet_id                     = module.networking.subnet_ids.utility_vms
  managed_identity_id           = module.security.managed_identity_ids["github-runner-identity"]
  managed_identity_principal_id = module.security.managed_identity_principal_ids["github-runner-identity"]
  subscription_id               = var.subscription_id
  container_registry_id         = azurerm_container_registry.invoiceapi.id
  github_repository             = var.github_repository
  github_token                  = var.github_token
  ssh_public_key_path           = var.github_runner_ssh_public_key_path
  tags                          = local.tags
}

# Container Registry (keeping this here as it's referenced by the GitHub runner)
resource "azurerm_container_registry" "invoiceapi" {
  name                     = "${local.prefix}acr"
  resource_group_name      = azurerm_resource_group.shared_rg.name
  location                 = azurerm_resource_group.shared_rg.location
  sku                      = "Premium"
  admin_enabled            = false
  public_network_access_enabled = false
  tags                     = local.tags
}

# Private Endpoint for Container Registry
resource "azurerm_private_endpoint" "acr_pe" {
  name                = "${local.prefix}-acr-pe"
  resource_group_name = azurerm_resource_group.shared_rg.name
  location            = azurerm_resource_group.shared_rg.location
  subnet_id           = module.networking.subnet_ids.services
  tags                = local.tags

  private_service_connection {
    name                           = "${local.prefix}-acr-psc"
    private_connection_resource_id = azurerm_container_registry.invoiceapi.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }

  private_dns_zone_group {
    name                 = "acr-dns-zone-group"
    private_dns_zone_ids = [module.networking.private_dns_zone_ids.container_registry]
  }
}

# Storage Module
module "storage" {
  source = "./modules/storage"
  
  resource_group_name = azurerm_resource_group.shared_rg.name
  location           = azurerm_resource_group.shared_rg.location
  environment        = "demo"
  project_name       = local.prefix
  
  # Storage configuration
  storage_account_tier        = "Standard"
  storage_account_replication = "LRS"
  enable_versioning          = true
  enable_soft_delete         = true
  
  containers = [
    {
      name   = "invoices"
      access = "private"
    },
    {
      name   = "processed"
      access = "private"
    },
    {
      name   = "archive"
      access = "private"
    }
  ]
  
  tags = local.tags
}

# Container Apps Module
module "container_apps" {
  source = "./modules/container-apps"
  
  resource_group_name = azurerm_resource_group.shared_rg.name
  location           = azurerm_resource_group.shared_rg.location
  environment        = "demo"
  project_name       = local.prefix
  
  # Dependencies
  subnet_id                    = module.networking.subnet_ids.container_apps
  log_analytics_workspace_id   = module.observability.log_analytics_workspace_id
  container_registry_id        = azurerm_container_registry.invoiceapi.id
  container_registry_server    = azurerm_container_registry.invoiceapi.login_server
  managed_identity_id          = module.security.managed_identity_ids["container-apps-identity"]
  
  # Container apps configuration (empty for now)
  container_apps = []
  dapr_enabled   = true
  
  tags = local.tags
}

# Function Apps Module
module "function_apps" {
  source = "./modules/function-apps"
  
  resource_group_name = azurerm_resource_group.shared_rg.name
  location           = azurerm_resource_group.shared_rg.location
  environment        = "demo"
  project_name       = local.prefix
  
  # Dependencies
  storage_account_name                   = module.storage.storage_account_name
  storage_account_access_key             = module.storage.storage_account_primary_key
  application_insights_key               = module.observability.application_insights_instrumentation_key
  application_insights_connection_string = module.observability.application_insights_connection_string
  key_vault_id                          = module.security.key_vault_id
  managed_identity_id                   = module.security.managed_identity_ids["function-apps-identity"]
  subnet_id                             = module.networking.subnet_ids.services
  
  # Function apps configuration (empty for now)
  function_apps            = []
  consumption_plan_enabled = true
  
  tags = local.tags
}

# AI Services Module
module "ai_services" {
  source = "./modules/ai-services"
  
  resource_group_name = azurerm_resource_group.shared_rg.name
  location           = azurerm_resource_group.shared_rg.location
  environment        = "demo"
  project_name       = local.prefix
  
  # Dependencies
  key_vault_id        = module.security.key_vault_id
  managed_identity_id = module.security.managed_identity_ids["ai-services-identity"]
  subnet_id          = module.networking.subnet_ids.services
  
  # AI services configuration
  openai_deployments = [
    {
      name     = "gpt-4"
      model    = "gpt-4"
      version  = "0613"
      capacity = 10
    },
    {
      name     = "gpt-35-turbo"
      model    = "gpt-35-turbo"
      version  = "0613"
      capacity = 10
    },
    {
      name     = "text-embedding-ada-002"
      model    = "text-embedding-ada-002"
      version  = "2"
      capacity = 10
    }
  ]
  
  form_recognizer_enabled    = true
  computer_vision_enabled    = false
  private_endpoints_enabled  = false
  
  tags = local.tags
}