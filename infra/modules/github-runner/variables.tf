variable "prefix" {
  description = "Prefix for resource naming"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region location"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "subnet_id" {
  description = "Subnet ID for the GitHub runner VM"
  type        = string
}

variable "managed_identity_id" {
  description = "ID of the managed identity for the GitHub runner"
  type        = string
}

variable "managed_identity_principal_id" {
  description = "Principal ID of the managed identity for role assignments"
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "container_registry_id" {
  description = "ID of the container registry for role assignments"
  type        = string
}

variable "github_repository" {
  description = "GitHub repository for the runner"
  type        = string
}

variable "github_token" {
  description = "GitHub token for runner registration"
  type        = string
  sensitive   = true
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "vm_size" {
  description = "Size of the GitHub runner VM"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}

variable "ubuntu_image" {
  description = "Ubuntu image configuration"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "24.04.202510010"
  }
}