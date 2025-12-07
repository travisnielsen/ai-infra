# Foundry Module Variables

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "resource_group_id" {
  description = "ID of the resource group (used as parent_id for azapi_resource)"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  
  validation {
    condition     = contains(["canadaeast", "eastus", "eastus2", "southcentralus", "westus", "westus3"], var.location)
    error_message = "The location must be one of: canadaeast, eastus, eastus2, southcentralus, westus, westus3."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "subdomain_name" {
  description = "To be used for the Foundry instance subdomain. Should be short and alphanumeric."
  type        = string
}

variable "sku" {
  description = "SKU for Foundry service"
  type        = string
  default     = "S0"
}

variable "model_deployments" {
  description = "Foundry model deployments"
  type = list(object({
    name     = string
    sku_name = string
    capacity = number
    model = object({
      format  = string
      name    = string
      version = string
    })
  }))
  default = null
}

variable "projects" {
  description = "List of Foundry projects to create"
  type = list(object({
    name         = string
    display_name = string
    description  = string
  }))
}

variable "disable_local_auth" {
  description = "Disable local authentication (API key)"
  type        = bool
  default     = true
}

variable "public_network_access" {
  description = "Public network access setting (Enabled or Disabled)"
  type        = string
  default     = "Disabled"
}

variable "foundry_subnet_id" {
  description = "Subnet ID for the private endpoint (optional)"
  type        = string
  default     = null
}


variable "agents_subnet_id" {
  description = "Subnet ID for VNet integration (optional)"
  type        = string
  default     = null
}

variable "dns_zone_ids" {
  description = "List of private DNS zone IDs for the private endpoint"
  type        = list(string)
  default     = []
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
    default_action        = "Deny"
    ip_rules             = []
    virtual_network_rules = []
  }
}

variable "enable_app_insights_connection" {
  description = "Enable Application Insights connection for Foundry"
  type        = bool
  default     = false
}

variable "app_insights_instrumentation_key" {
  description = "Application Insights Instrumentation Key (optional)"
  type        = string
  default     = ""
}

variable "app_insights_resource_id" {
  description = "Application Insights Resource ID (optional)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}