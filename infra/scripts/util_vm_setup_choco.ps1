# Enable Hyper-V
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -All -NoRestart

# Install Chocolatey (works in SYSTEM context unlike winget)
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Refresh environment to get choco command
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Install software using Chocolatey
choco install powershell-core -y
choco install azure-cli -y
choco install azure-functions-core-tools -y
choco install git -y
choco install vscode -y
choco install python313 -y
choco install gh -y
choco install docker-desktop -y

# Install PowerShell modules
# Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name PowerShellGet -Force -AllowClobber -SkipPublisherCheck
Install-Module -Name Az -Repository PSGallery -Force -SkipPublisherCheck

# Restart the computer
Restart-Computer -Force
