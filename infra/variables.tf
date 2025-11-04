variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID to deploy environment into."
}

variable "region" {
  type    = string
  default = "centralus"
  description = "Azure region to deploy resources."
}

variable "region_aifoundry" {
  type    = string
  default = "eastus2"
  description = "Azure region to deploy AI Foundry resources."
}

variable "cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "Network range for created virtual network."
}

variable "utility_vm_admin_password" {
  type        = string
  description = "Admin password for utility VM."
  sensitive   = true
}