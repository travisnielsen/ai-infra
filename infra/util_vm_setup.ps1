Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -All -NoRestart
winget install --id Microsoft.PowerShell --source winget
winget install --id Microsoft.AzureCLI -e
winget install --id Microsoft.Azure.FunctionsCoreTools -e
winget install --id Git.Git -e --source winget
winget install --id Microsoft.VisualStudioCode
winget install --id Python.Python.3.13 -e
winget install --id GitHub.cli -e
winget install --id Docker.DockerDesktop -e
Install-Module -Name Az -Repository PSGallery -Force