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

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "sku" {
  description = "SKU for the Container Registry"
  type        = string
  default     = "Premium"
}

variable "public_network_access_enabled" {
  description = "Enable public network access to Container Registry"
  type        = bool
  default     = false
}

variable "anonymous_pull_enabled" {
  description = "Enable anonymous pull for Container Registry"
  type        = bool
  default     = false
}

variable "enable_private_endpoints" {
  description = "Enable private endpoints for Container Registry"
  type        = bool
  default     = false
}

variable "private_endpoint_info" {
  description = "Private endpoint configuration (subnet_id and dns_zone_id)"
  type = object({
    subnet_id   = string
    dns_zone_id = string
  })
  default = null
  nullable = true
}