output "vm_id" {
  description = "ID of the GitHub runner VM"
  value       = azurerm_linux_virtual_machine.github_runner_vm.id
}

output "vm_name" {
  description = "Name of the GitHub runner VM"
  value       = azurerm_linux_virtual_machine.github_runner_vm.name
}

output "vm_private_ip" {
  description = "Private IP address of the GitHub runner VM"
  value       = azurerm_linux_virtual_machine.github_runner_vm.private_ip_address
}

output "network_interface_id" {
  description = "ID of the network interface"
  value       = azurerm_network_interface.github_runner_nic.id
}