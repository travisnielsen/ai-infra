# Function Apps Module Variables

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

variable "storage_account_name" {
  description = "Storage account name for Function App"
  type        = string
}

variable "storage_account_access_key" {
  description = "Storage account access key"
  type        = string
  sensitive   = true
}

variable "application_insights_key" {
  description = "Application Insights instrumentation key"
  type        = string
  sensitive   = true
}

variable "application_insights_connection_string" {
  description = "Application Insights connection string"
  type        = string
  sensitive   = true
}

variable "key_vault_id" {
  description = "Key Vault ID for storing secrets"
  type        = string
}

variable "managed_identity_id" {
  description = "Managed identity ID for accessing resources"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for VNet integration (optional)"
  type        = string
  default     = ""
}

variable "function_apps" {
  description = "Configuration for function apps"
  type = list(object({
    name                    = string
    os_type                 = string # "linux" or "windows"
    runtime_stack          = string # "python", "node", "dotnet", etc.
    runtime_version        = string
    service_plan_sku       = string # "Y1", "EP1", "P1v2", etc.
    always_on              = bool
    app_settings           = map(string)
    connection_strings     = map(string)
    enable_vnet_integration = bool
  }))
  default = []
}

variable "consumption_plan_enabled" {
  description = "Use consumption plan for cost optimization"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}