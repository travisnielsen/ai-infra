# Additional Modules Documentation

This document provides detailed information about the additional modules implemented in the modular Terraform architecture.

## 📦 Storage Module (`modules/storage/`)

### Purpose
Provides Azure Storage accounts with blob containers and file shares for application data storage.

### Key Features
- **Storage Account**: Configurable tier (Standard/Premium) and replication (LRS/GRS/ZRS)
- **Blob Storage**: Multiple containers with private access by default
- **Versioning**: Blob versioning enabled for data protection
- **Soft Delete**: Configurable retention period for deleted blobs
- **File Shares**: Optional Azure Files for shared storage scenarios
- **Security**: Network access controls and optional private endpoints

### Default Configuration
```terraform
containers = [
  { name = "invoices", access = "private" },
  { name = "processed", access = "private" },
  { name = "archive", access = "private" }
]
```

### Outputs
- Storage account name and connection details
- Container URLs for application access
- File share URLs (if configured)

---

## 🚀 Container Apps Module (`modules/container-apps/`)

### Purpose
Serverless container platform for microservices with Dapr integration and auto-scaling.

### Key Features
- **Container Apps Environment**: Dedicated environment with VNet integration
- **Multi-App Support**: Deploy multiple containerized applications
- **Dapr Integration**: Built-in support for distributed application runtime
- **Auto-Scaling**: Traffic-based and metric-based scaling
- **Registry Integration**: Seamless Azure Container Registry integration
- **Ingress**: External and internal traffic routing

### Configuration Options
```terraform
container_apps = [
  {
    name          = "api"
    image         = "myapp:latest"
    cpu           = 0.25
    memory        = "0.5Gi"
    min_replicas  = 1
    max_replicas  = 10
    external_ingress = true
    target_port   = 8080
  }
]
```

### Outputs
- Container Apps Environment details
- Individual app URLs and endpoints
- Revision information

---

## ⚡ Function Apps Module (`modules/function-apps/`)

### Purpose
Serverless compute platform for event-driven applications and background processing.

### Key Features
- **Multi-Platform**: Support for both Linux and Windows function apps
- **Runtime Flexibility**: Python, Node.js, .NET, Java, PowerShell
- **Scaling Options**: Consumption plan or dedicated App Service plans
- **VNet Integration**: Secure connectivity to private resources
- **Monitoring**: Built-in Application Insights integration
- **Identity**: Managed identity for secure resource access

### Configuration Example
```terraform
function_apps = [
  {
    name                    = "invoice-processor"
    os_type                 = "linux"
    runtime_stack          = "python"
    runtime_version        = "3.11"
    service_plan_sku       = "Y1"  # Consumption
    always_on              = false
    enable_vnet_integration = true
    app_settings = {
      "CUSTOM_SETTING" = "value"
    }
    connection_strings = {}
  }
]
```

### Outputs
- Function app URLs and hostnames
- Managed identity principal IDs
- Service plan information

---

## 🧠 AI Services Module (`modules/ai-services/`)

### Purpose
Azure Cognitive Services integration for AI-powered applications, including OpenAI models.

### Key Features
- **Azure OpenAI**: GPT-4, GPT-3.5-turbo, and embedding models
- **Form Recognizer**: Document Intelligence for invoice processing
- **Computer Vision**: Image analysis and OCR capabilities
- **Security**: Private endpoints and network restrictions
- **Key Management**: API keys stored securely in Key Vault
- **Flexible Deployments**: Configurable model deployments and capacity

### Default OpenAI Deployments
```terraform
openai_deployments = [
  {
    name     = "gpt-4"
    model    = "gpt-4"
    version  = "0613"
    capacity = 10
  },
  {
    name     = "gpt-35-turbo"
    model    = "gpt-35-turbo"
    version  = "0613"
    capacity = 10
  },
  {
    name     = "text-embedding-ada-002"
    model    = "text-embedding-ada-002"
    version  = "2"
    capacity = 10
  }
]
```

### Security Features
- Network access controls
- Private endpoint support
- Key Vault integration for secret management
- Managed identity authentication

### Outputs
- Service endpoints for all AI services
- Model deployment information
- Key Vault secret references

---

## 🔧 Module Dependencies

The modules are designed with clear dependency relationships:

```
Storage ← Function Apps
      ← Container Apps

Security → All Modules (Key Vault, Identities)
Networking → All Modules (Subnets, DNS)
Observability → Function Apps, Container Apps
```

## 🎯 Usage Examples

### Basic Storage Usage
```terraform
module "storage" {
  source = "./modules/storage"
  
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  environment        = "production"
  project_name       = "myapp"
  
  # Custom containers
  containers = [
    { name = "uploads", access = "private" },
    { name = "public-assets", access = "blob" }
  ]
  
  # Enable file shares
  file_shares = [
    { name = "shared-data", quota = 100 }
  ]
}
```

### Function App with AI Services
```terraform
module "function_apps" {
  source = "./modules/function-apps"
  
  # ... basic configuration ...
  
  function_apps = [
    {
      name           = "document-processor"
      os_type        = "linux"
      runtime_stack  = "python"
      runtime_version = "3.11"
      app_settings = {
        "OPENAI_ENDPOINT" = module.ai_services.service_endpoints.openai
        "FORM_RECOGNIZER_ENDPOINT" = module.ai_services.service_endpoints.form_recognizer
      }
    }
  ]
}
```

## 📊 Monitoring and Observability

All modules integrate with the observability module for:
- **Centralized Logging**: All logs flow to Log Analytics
- **Application Insights**: Performance and error tracking
- **Metrics**: Resource utilization and performance metrics
- **Alerts**: Proactive monitoring and notifications

## 🔒 Security Best Practices

Each module implements security best practices:
- **Managed Identities**: No stored credentials
- **Private Endpoints**: Secure network connectivity
- **Key Vault Integration**: Centralized secret management
- **Network Security**: Restrictive network access controls
- **Encryption**: Data encrypted at rest and in transit