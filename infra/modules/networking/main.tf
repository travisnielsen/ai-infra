# Virtual Network
resource "azurerm_virtual_network" "workload_vnet" {
  name                = var.prefix
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = [var.cidr]
  tags                = var.tags
}

# Network Security Groups
resource "azurerm_network_security_group" "dmz_nsg" {
  name                = "${var.prefix}-dmz"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_network_security_group" "compute_nsg" {
  name                = "${var.prefix}-compute"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# Subnets
resource "azurerm_subnet" "dmz" {
  name                 = "dmz"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.workload_vnet.name
  address_prefixes     = [cidrsubnet(var.cidr, 8, 0)]
}

resource "azurerm_subnet" "services" {
  name                 = "services"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.workload_vnet.name
  address_prefixes     = [cidrsubnet(var.cidr, 8, 1)]
}

resource "azurerm_subnet" "function_apps" {
  name                 = "functionapps"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.workload_vnet.name
  address_prefixes     = [cidrsubnet(var.cidr, 8, 2)]

  delegation {
    name = "function-apps-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "utility_vms" {
  name                 = "utility"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.workload_vnet.name
  address_prefixes     = [cidrsubnet(var.cidr, 8, 3)]
}

resource "azurerm_subnet" "container_apps" {
  name                 = "containerapps"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.workload_vnet.name
  address_prefixes     = [cidrsubnet(var.cidr, 7, 4)]
  
  delegation {
    name = "container-app-delegation"
    service_delegation {
      name = "Microsoft.App/environments"
    }
  }
}

resource "azurerm_subnet" "aifoundry" {
  name                 = "aifoundry"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.workload_vnet.name
  address_prefixes     = [cidrsubnet(var.cidr, 8, 6)]
}

# NSG Associations
resource "azurerm_subnet_network_security_group_association" "nsg_dmz" {
  subnet_id                 = azurerm_subnet.dmz.id
  network_security_group_id = azurerm_network_security_group.dmz_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "nsg_services" {
  subnet_id                 = azurerm_subnet.services.id
  network_security_group_id = azurerm_network_security_group.compute_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "nsg_function_apps" {
  subnet_id                 = azurerm_subnet.function_apps.id
  network_security_group_id = azurerm_network_security_group.compute_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "nsg_container_apps" {
  subnet_id                 = azurerm_subnet.container_apps.id
  network_security_group_id = azurerm_network_security_group.compute_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "nsg_aifoundry" {
  subnet_id                 = azurerm_subnet.aifoundry.id
  network_security_group_id = azurerm_network_security_group.compute_nsg.id
}

# Private DNS Zones
resource "azurerm_private_dns_zone" "zones" {
  for_each = var.enable_private_dns_zones ? { for zone in var.private_dns_zones : zone.name => zone } : {}
  
  name                = each.value.zone_name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "zone_links" {
  for_each = var.enable_private_dns_zones ? { for zone in var.private_dns_zones : zone.name => zone } : {}
  
  name                  = "${each.value.name}-dns-zone-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.zones[each.key].name
  virtual_network_id    = azurerm_virtual_network.workload_vnet.id
  tags                  = var.tags
}