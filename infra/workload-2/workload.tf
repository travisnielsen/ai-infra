# Define Workload Infrastructure

##################################################
# Networking Module
##################################################

module "networking" {
  source              = "../modules/networking"
  prefix              = local.identifier
  resource_group_name = azurerm_resource_group.shared_rg.name
  location            = azurerm_resource_group.shared_rg.location
  cidr                = var.cidr
  tags                = local.tags
  
  # Define Network Security Groups
  network_security_groups = {
    dmz = {
      name = "dmz"
    }
    compute = {
      name = "compute"
    }
    services = {
      name = "services"
    }
  }
  
  # Define Subnets with their configurations
  subnets = {
    AzureFirewallSubnet = {
      address_prefix = cidrsubnet(var.cidr, 10, 0) # 10.0.0.0/26 for firewall (10.0.0.0 - 10.0.0.63)
    }  
    dmz = {
      address_prefix = cidrsubnet(var.cidr, 10, 1) # 10.0.0.64/26 for dmz (10.0.0.64 - 10.0.0.127)
      nsg_name       = "dmz"
    }
    services = {
      address_prefix = cidrsubnet(var.cidr, 8, 1)
      nsg_name       = "services"
    }
    utility = {
      address_prefix = cidrsubnet(var.cidr, 8, 3)
      nsg_name       = "compute"
    }
  }
}


##################################################
# GitHub Runner Module
##################################################

/*
module "github_runner" {
  source                        = "./modules/github-runner"
  prefix                        = local.prefix
  resource_group_name           = azurerm_resource_group.shared_rg.name
  location                      = azurerm_resource_group.shared_rg.location
  subnet_id                     = module.networking.subnet_ids["utility"]
  managed_identity_id           = module.security.managed_identity_ids["github-runner-identity"]
  managed_identity_principal_id = module.security.managed_identity_principal_ids["github-runner-identity"]
  subscription_id               = var.subscription_id
  container_registry_id         = module.container_registry.container_registry_id
  github_repository             = var.github_repository
  github_token                  = var.github_token
  ssh_public_key_path           = var.github_runner_ssh_public_key_path
  tags                          = local.tags
}
*/


##################################################
# Virtual Machine Module (Utility VM)
##################################################

module "utility_vm" {
  source                = "../modules/virtual-machines"
  resource_group_name   = azurerm_resource_group.shared_rg.name
  location              = azurerm_resource_group.shared_rg.location
  tags                  = local.tags
  prefix                = local.identifier
  computer_name         = "${local.identifier}-util"
  
  # Networking
  subnet_id             = module.networking.subnet_ids["utility"]
  
  # VM Configuration
  vm_size               = "Standard_D4s_v3"
  admin_username        = "azureuser"
  admin_password        = var.utility_vm_admin_password

  # Pass the script content to be executed via Custom Script Extension
  setup_script          = templatefile("${path.module}/../scripts/util_vm_setup_choco.ps1", {})
  setup_script_name     = "util_vm_setup_choco.ps1"
}


##################################################
# Azure Bastion
##################################################

module "bastion" {
  source                  = "../modules/bastion"
  prefix                  = local.identifier
  resource_group_name     = azurerm_resource_group.shared_rg.name
  location                = azurerm_resource_group.shared_rg.location
  virtual_network_name    = module.networking.virtual_network_name
  subnet_address_prefix   = cidrsubnet(var.cidr, 10, 2) # 10.0.0.128/26 for bastion (10.0.0.128 - 10.0.0.191)
  sku                     = "Basic" # "Basic", "Standard", "Developer"
  copy_paste_enabled      = true
  enable_tunneling        = false
  enable_ip_connect       = false
  enable_shareable_link   = false
  enable_file_copy        = false
  tags                    = local.tags
}
