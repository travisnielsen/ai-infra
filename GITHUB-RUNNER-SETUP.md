# GitHub Self-Hosted Runner Setup for Azure

This document explains how to configure your GitHub repository to use the self-hosted runner with Azure managed identity authentication.

## Overview

The infrastructure creates a self-hosted GitHub runner VM with:

- Azure CLI pre-installed and configured
- Docker with buildx for multi-platform builds  
- Terraform for infrastructure management
- PowerShell for additional scripting
- Managed identity for secure Azure authentication

## Required GitHub Secrets

After running `terraform apply`, you'll need to configure these secrets in your GitHub repository:

### 1. Get Terraform Outputs

Run this command to get the required values:

```bash
cd infra
terraform output
```

### 2. Configure GitHub Repository Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions → Repository secrets

Add these secrets using the terraform output values:

| Secret Name | Description | Terraform Output |
|-------------|-------------|------------------|
| `AZURE_CLIENT_ID` | Managed identity client ID | `github_runner_client_id` |
| `AZURE_TENANT_ID` | Azure tenant ID | `azure_tenant_id` |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID | `azure_subscription_id` |
| `CONTAINER_REGISTRY` | Azure Container Registry URL | `container_registry_login_server` |
| `RESOURCE_GROUP` | Azure resource group name | `resource_group_name` |
| `GH_TOKEN` | GitHub personal access token | *(create manually)* |

### 3. Create GitHub Personal Access Token

1. Go to GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate new token with these scopes:
   - `repo` (Full control of private repositories)
   - `workflow` (Update GitHub Action workflows)
3. Copy the token and add it as `GH_TOKEN` secret

## Runner Registration

The GitHub runner will automatically register itself with your repository using the provided GitHub token. You can verify the runner is active by going to:

Repository → Settings → Actions → Runners

## Workflow Features

The included workflow (`.github/workflows/azure-deploy.yml`) demonstrates:

### Azure Authentication

- Uses managed identity for secure, passwordless authentication
- No need to store service principal credentials
- Automatic token renewal

### Multi-Platform Docker Builds

- Builds for both AMD64 and ARM64 architectures
- Pushes to your Azure Container Registry
- Uses Docker buildx for cross-platform support

### Infrastructure as Code

- Terraform plan and apply operations
- Conditional deployment based on file changes
- Infrastructure updates on infrastructure file changes

### Container App Deployment

- Automatic container app updates with new images
- Rolling deployments with zero downtime
- Integration with Azure Container Registry

## Security Benefits

1. **No stored credentials**: Uses Azure managed identity
2. **Least privilege**: Runner identity has only necessary permissions
3. **Secure communication**: All Azure operations use managed identity tokens
4. **Audit trail**: All operations are logged in Azure Activity Log

## Usage Examples

### Manual Deployment

Trigger a manual deployment:

```bash
# In GitHub UI: Actions → Azure Deployment → Run workflow
```

### Automatic Deployment

Push changes to trigger automatic deployment:

```bash
git add .
git commit -m "Update application"
git push origin main
```

## Troubleshooting

### Runner Not Appearing

1. Check VM is running: `az vm list --resource-group <rg-name> --output table`
2. SSH to VM and check runner service: `sudo systemctl status actions.runner.ai-infra.service`

### Authentication Issues

1. Verify managed identity: `az vm identity show --resource-group <rg-name> --name github-runner`
2. Check role assignments: `az role assignment list --assignee <principal-id>`

### Docker Build Issues

1. Ensure buildx is available: `docker buildx ls`
2. Check registry authentication: `az acr login --name <registry-name>`

## Next Steps

1. Run `terraform apply` to create the infrastructure
2. Configure the GitHub secrets using terraform outputs
3. Push a change to trigger the first workflow run
4. Monitor the Actions tab to see your self-hosted runner in action

The runner will automatically handle Azure authentication, Docker builds, and infrastructure deployments without requiring any stored credentials in GitHub.