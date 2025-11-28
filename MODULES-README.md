# Terraform Modules Architecture

This repository has been refactored to use a modular Terraform architecture for better maintainability, reusability, and composability.

## Module Structure

## 📁 Module Directory Structure

```
infra/modules/
├── networking/           # VNet, subnets, NSGs, DNS
├── security/            # Key Vault, managed identities, RBAC
├── observability/       # Log Analytics, Application Insights
├── github-runner/       # Self-hosted GitHub Actions runner
├── storage/            # Storage accounts, containers, file shares
├── container-apps/     # Azure Container Apps with Dapr support
├── function-apps/      # Azure Functions (Linux/Windows)
└── ai-services/        # OpenAI, Form Recognizer, Computer Vision
```

## Benefits of Modular Architecture

### 1. **Separation of Concerns**
- Each module handles a specific domain (networking, security, compute)
- Easier to understand and maintain individual components
- Clear boundaries between different infrastructure layers

### 2. **Reusability**
- Modules can be reused across different environments
- Consistent infrastructure patterns across projects
- Easy to share common components

### 3. **Composability**
- Mix and match modules as needed
- Enable/disable specific components easily
- Build different architectural patterns from the same modules

### 4. **Maintainability**
- Smaller, focused files are easier to work with
- Changes to one module don't affect others
- Better version control and code review experience

### 5. **Testing**
- Test individual modules in isolation
- Validate module interfaces and contracts
- Easier to troubleshoot specific components

## Module Descriptions

### Networking Module (`modules/networking/`)
**Purpose**: Provides core networking infrastructure
**Resources**:
- Virtual Network with configurable CIDR
- Multiple subnets (DMZ, services, function apps, utility VMs, container apps, AI foundry)
- Network Security Groups with associations
- Private DNS zones for various Azure services

**Key Features**:
- Automatic subnet calculation using `cidrsubnet()`
- Configurable private DNS zones
- Proper subnet delegations for specialized services

### Security Module (`modules/security/`)
**Purpose**: Manages security and identity resources
**Resources**:
- Azure Key Vault with private endpoint
- User-assigned managed identities
- Access policies and permissions

**Key Features**:
- Configurable managed identities
- Secure Key Vault with private networking
- Proper access policies for current user

### Observability Module (`modules/observability/`)
**Purpose**: Provides monitoring and logging capabilities
**Resources**:
- Log Analytics Workspace
- Application Insights

**Key Features**:
- Configurable retention periods
- Proper workspace integration

### GitHub Runner Module (`modules/github-runner/`)
**Purpose**: Self-hosted GitHub Actions runner infrastructure
**Resources**:
- Ubuntu 24.04 LTS virtual machine
- Network interface and security
- Azure role assignments
- Complete toolchain installation (Docker, Terraform, Azure CLI)

**Key Features**:
- Automated tool installation
- Managed identity authentication
- Secure SSH key authentication
- GitHub runner registration script

## Migration from Monolithic to Modular

### Option 1: Fresh Deployment (Recommended for new environments)
1. Use `main-modular.tf` and `outputs-modular.tf`
2. Deploy to a new resource group
3. Migrate applications and data as needed

### Option 2: In-Place Migration (Advanced)
1. Use Terraform state manipulation
2. Move resources to modules gradually
3. Requires careful state management

## Usage Examples

### Basic Deployment
```bash
# Initialize with modules
terraform init

# Plan using modular configuration
terraform plan -var-file="terraform.tfvars"

# Apply modular infrastructure
terraform apply
```

### Custom Module Configuration
```hcl
module "networking" {
  source = "./modules/networking"
  
  prefix              = "myapp"
  resource_group_name = "myapp-rg"
  location            = "East US"
  cidr                = "10.1.0.0/16"
  
  # Customize private DNS zones
  enable_private_dns_zones = true
  private_dns_zones = [
    {
      name      = "storage_blob"
      zone_name = "privatelink.blob.core.windows.net"
      description = "Custom storage DNS zone"
    }
  ]
}
```

### Environment-Specific Configurations
```hcl
# Development environment
module "github_runner" {
  source = "./modules/github-runner"
  
  vm_size = "Standard_B2s"  # Smaller VM for dev
  ubuntu_image = {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}

# Production environment
module "github_runner" {
  source = "./modules/github-runner"
  
  vm_size = "Standard_D4s_v3"  # Larger VM for production
  ubuntu_image = {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "24.04.202510010"  # Pinned version
  }
}
```

## Module Development Guidelines

### 1. **Input Variables**
- Use descriptive variable names
- Provide default values where appropriate
- Include validation rules when needed
- Document all variables

### 2. **Outputs**
- Export all useful resource attributes
- Use consistent naming conventions
- Mark sensitive outputs appropriately
- Provide descriptions

### 3. **Dependencies**
- Minimize cross-module dependencies
- Use explicit input variables instead of data sources
- Document any required dependencies

### 4. **Versioning**
- Use semantic versioning for modules
- Tag stable releases
- Maintain backward compatibility when possible

## Future Enhancements

### Planned Modules
- **Container Apps Module**: Complete container apps environment
- **Function Apps Module**: Function apps with all configurations
- **AI Services Module**: Cosmos DB, Document Intelligence, AI Foundry
- **Storage Module**: Storage accounts with different configurations

### Advanced Features
- **Module Registry**: Private Terraform module registry
- **Testing Framework**: Automated module testing with Terratest
- **Policy as Code**: Azure Policy integration
- **Cost Management**: Resource tagging and cost allocation

## Troubleshooting

### Common Issues
1. **Module Not Found**: Ensure `terraform init` has been run
2. **Variable Conflicts**: Check variable names across modules
3. **State Issues**: Use `terraform state` commands for debugging
4. **Dependency Cycles**: Review module dependencies

### Best Practices
- Always run `terraform plan` before `apply`
- Use remote state for team collaboration
- Implement proper CI/CD for infrastructure changes
- Regular module updates and security reviews

## Contributing

When adding new modules:
1. Follow the established directory structure
2. Include all three files: `main.tf`, `variables.tf`, `outputs.tf`
3. Add comprehensive documentation
4. Test with different input combinations
5. Update this README with module information