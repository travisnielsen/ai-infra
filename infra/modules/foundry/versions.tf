terraform {
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.6"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.40"
    }
    # https://registry.terraform.io/providers/hashicorp/time/latest
    time = {
      source  = "hashicorp/time"
      version = "~> 0.13"
    }
  }
}
