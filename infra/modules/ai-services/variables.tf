# AI Services Module Variables

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "key_vault_id" {
  description = "Key Vault ID for storing secrets"
  type        = string
}

variable "managed_identity_id" {
  description = "Managed identity ID for accessing resources"
  type        = string
}

variable "cognitive_services" {
  description = "Configuration for Cognitive Services"
  type = list(object({
    name             = string
    kind             = string # "OpenAI", "FormRecognizer", "ComputerVision", etc.
    sku_name         = string
    custom_subdomain = bool
    deployments = list(object({
      name  = string
      model = object({
        format  = string
        name    = string
        version = string
      })
      scale = object({
        type     = string
        capacity = number
      })
    }))
  }))
  default = []
}

variable "openai_deployments" {
  description = "OpenAI model deployments"
  type = list(object({
    name     = string
    model    = string
    version  = string
    capacity = number
  }))
  default = [
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
}

variable "form_recognizer_enabled" {
  description = "Enable Azure Form Recognizer (Document Intelligence)"
  type        = bool
  default     = true
}

variable "computer_vision_enabled" {
  description = "Enable Azure Computer Vision"
  type        = bool
  default     = false
}

variable "private_endpoints_enabled" {
  description = "Enable private endpoints for AI services"
  type        = bool
  default     = false
}

variable "subnet_id" {
  description = "Subnet ID for private endpoints (if enabled)"
  type        = string
  default     = ""
}

variable "network_restrictions" {
  description = "Network access restrictions"
  type = object({
    default_action = string
    ip_rules       = list(string)
    virtual_network_rules = list(object({
      subnet_id = string
    }))
  })
  default = {
    default_action        = "Allow"
    ip_rules             = []
    virtual_network_rules = []
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}