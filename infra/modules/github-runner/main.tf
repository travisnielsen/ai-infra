# Network Interface
resource "azurerm_network_interface" "github_runner_nic" {
  name                = "${var.prefix}-gh-runner-nic"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "github_runner_vm" {
  name                = "${var.prefix}-gh-runner"
  computer_name       = "ghrunner"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  tags                = var.tags

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  network_interface_ids = [
    azurerm_network_interface.github_runner_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = var.ubuntu_image.publisher
    offer     = var.ubuntu_image.offer
    sku       = var.ubuntu_image.sku
    version   = var.ubuntu_image.version
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }

  custom_data = base64encode(templatefile("${path.module}/runner-setup.sh", {
    github_repository = var.github_repository
    github_token      = var.github_token
  }))
}

# Role Assignments for GitHub Runner Identity
resource "azurerm_role_assignment" "github_runner_contributor" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = var.managed_identity_principal_id
}

resource "azurerm_role_assignment" "github_runner_acr_push" {
  scope                = var.container_registry_id
  role_definition_name = "AcrPush"
  principal_id         = var.managed_identity_principal_id
}

resource "azurerm_role_assignment" "github_runner_acr_pull" {
  scope                = var.container_registry_id
  role_definition_name = "AcrPull"
  principal_id         = var.managed_identity_principal_id
}