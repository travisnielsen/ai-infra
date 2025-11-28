# Storage Account
resource "azurerm_storage_account" "main" {
  name                = "${var.project_name}${var.environment}sa"
  resource_group_name = var.resource_group_name
  location            = var.location

  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication
  account_kind             = "StorageV2"

  # Security settings
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = true

  # Enable advanced features
  is_hns_enabled = true # Hierarchical namespace for Data Lake

  blob_properties {
    versioning_enabled = var.enable_versioning
    
    dynamic "delete_retention_policy" {
      for_each = var.enable_soft_delete ? [1] : []
      content {
        days = var.soft_delete_retention_days
      }
    }

    dynamic "container_delete_retention_policy" {
      for_each = var.enable_soft_delete ? [1] : []
      content {
        days = var.soft_delete_retention_days
      }
    }
  }

  tags = merge(var.tags, {
    Module = "storage"
  })
}

# Storage Containers
resource "azurerm_storage_container" "containers" {
  for_each = {
    for container in var.containers : container.name => container
  }

  name                  = each.value.name
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = each.value.access
}

# File Shares
resource "azurerm_storage_share" "shares" {
  for_each = {
    for share in var.file_shares : share.name => share
  }

  name               = each.value.name
  storage_account_id = azurerm_storage_account.main.id
  quota              = each.value.quota
}

# Storage Account Network Rules (optional - restrictive access)
resource "azurerm_storage_account_network_rules" "main" {
  storage_account_id = azurerm_storage_account.main.id

  default_action             = "Allow"
  ip_rules                   = []
  virtual_network_subnet_ids = []
  bypass                     = ["Metrics", "Logging", "AzureServices"]
}

# Private Endpoint for Storage Account (optional)
resource "azurerm_private_endpoint" "storage_blob" {
  count               = 0 # Set to 1 to enable
  name                = "${azurerm_storage_account.main.name}-blob-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = "" # Add subnet ID if enabling

  private_service_connection {
    name                           = "${azurerm_storage_account.main.name}-blob-psc"
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  tags = merge(var.tags, {
    Module = "storage"
  })
}