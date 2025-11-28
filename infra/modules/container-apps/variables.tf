# Container Apps Module Variables

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

variable "subnet_id" {
  description = "Subnet ID for Container Apps Environment"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for monitoring"
  type        = string
}

variable "container_registry_id" {
  description = "Container Registry ID for pulling images"
  type        = string
}

variable "container_registry_server" {
  description = "Container Registry server URL"
  type        = string
}

variable "managed_identity_id" {
  description = "Managed identity ID for accessing resources"
  type        = string
}

variable "container_apps" {
  description = "Configuration for container apps"
  type = list(object({
    name          = string
    image         = string
    cpu           = number
    memory        = string
    min_replicas  = number
    max_replicas  = number
    target_port   = number
    external_ingress = bool
    env_vars = list(object({
      name  = string
      value = string
    }))
    secrets = list(object({
      name  = string
      value = string
    }))
  }))
  default = []
}

variable "dapr_enabled" {
  description = "Enable Dapr for the Container Apps Environment"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}