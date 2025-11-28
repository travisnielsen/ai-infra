#!/bin/bash

# Update system and install dependencies
apt-get update
apt-get install -y curl wget gpg lsb-release software-properties-common apt-transport-https ca-certificates gnupg

# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add azureuser to docker group
usermod -aG docker azureuser

# Install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
apt-get update
apt-get install -y terraform

# Install PowerShell
wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
apt-get update
apt-get install -y powershell

# Create GitHub Actions runner directory
mkdir -p /opt/actions-runner
cd /opt/actions-runner

# Download and extract GitHub Actions runner
RUNNER_VERSION="2.321.0"
curl -o actions-runner-linux-x64-$RUNNER_VERSION.tar.gz -L https://github.com/actions/runner/releases/download/v$RUNNER_VERSION/actions-runner-linux-x64-$RUNNER_VERSION.tar.gz
tar xzf ./actions-runner-linux-x64-$RUNNER_VERSION.tar.gz

# Set ownership
chown -R azureuser:azureuser /opt/actions-runner

# Configure the runner (will be done by the user)
cat > /opt/actions-runner/configure-runner.sh << 'EOL'
#!/bin/bash
cd /opt/actions-runner
./config.sh --url https://github.com/${github_repository} --token ${github_token} --name "$(hostname)" --work _work --runasservice
sudo ./svc.sh install azureuser
sudo ./svc.sh start
EOL

chmod +x /opt/actions-runner/configure-runner.sh
chown azureuser:azureuser /opt/actions-runner/configure-runner.sh

# Run the configuration as azureuser
sudo -u azureuser /opt/actions-runner/configure-runner.sh

# Install additional tools for development
apt-get install -y git jq unzip

# Install Node.js and npm
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# Install Python and pip
apt-get install -y python3 python3-pip python3-venv

# Clean up
apt-get autoremove -y
apt-get autoclean