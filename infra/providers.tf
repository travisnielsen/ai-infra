terraform {
  required_providers {
    azurerm = "~> 4.0"
    random  = "~> 3.6"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
