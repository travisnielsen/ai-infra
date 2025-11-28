output "virtual_network_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.workload_vnet.id
}

output "virtual_network_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.workload_vnet.name
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value = {
    dmz           = azurerm_subnet.dmz.id
    services      = azurerm_subnet.services.id
    function_apps = azurerm_subnet.function_apps.id
    utility_vms   = azurerm_subnet.utility_vms.id
    container_apps = azurerm_subnet.container_apps.id
    aifoundry     = azurerm_subnet.aifoundry.id
  }
}

output "subnet_address_prefixes" {
  description = "Map of subnet names to address prefixes"
  value = {
    dmz           = azurerm_subnet.dmz.address_prefixes[0]
    services      = azurerm_subnet.services.address_prefixes[0]
    function_apps = azurerm_subnet.function_apps.address_prefixes[0]
    utility_vms   = azurerm_subnet.utility_vms.address_prefixes[0]
    container_apps = azurerm_subnet.container_apps.address_prefixes[0]
    aifoundry     = azurerm_subnet.aifoundry.address_prefixes[0]
  }
}

output "network_security_group_ids" {
  description = "Map of NSG names to IDs"
  value = {
    dmz     = azurerm_network_security_group.dmz_nsg.id
    compute = azurerm_network_security_group.compute_nsg.id
  }
}

output "private_dns_zone_ids" {
  description = "Map of private DNS zone names to IDs"
  value       = { for k, v in azurerm_private_dns_zone.zones : k => v.id }
}

output "private_dns_zone_names" {
  description = "Map of private DNS zone names to DNS names"
  value       = { for k, v in azurerm_private_dns_zone.zones : k => v.name }
}