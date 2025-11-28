# User Assigned Managed Identities
resource "azurerm_user_assigned_identity" "identities" {
  for_each = { for identity in var.managed_identities : identity.name => identity }
  
  name                = "${var.prefix}-${each.value.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# Key Vault
resource "azurerm_key_vault" "invoicekv" {
  name                       = "${var.prefix}kv"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  tenant_id                  = var.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = false
  soft_delete_retention_days = 7
  public_network_access_enabled = false
  tags                       = var.tags

  access_policy {
    tenant_id = var.tenant_id
    object_id = var.current_user_object_id

    key_permissions = [
      "Get", "List", "Update", "Create", "Import", "Delete", "Recover",
      "Backup", "Restore", "Decrypt", "Encrypt", "UnwrapKey", "WrapKey",
      "Verify", "Sign", "Purge"
    ]

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"
    ]

    certificate_permissions = [
      "Get", "List", "Update", "Create", "Import", "Delete", "Recover",
      "Backup", "Restore", "ManageContacts", "ManageIssuers", "GetIssuers",
      "ListIssuers", "SetIssuers", "DeleteIssuers", "Purge"
    ]
  }
}

# Private Endpoint for Key Vault
resource "azurerm_private_endpoint" "keyvault_pe" {
  name                = "${var.prefix}-kv-pe"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${var.prefix}-kv-psc"
    private_connection_resource_id = azurerm_key_vault.invoicekv.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name                 = "keyvault-dns-zone-group"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }
}