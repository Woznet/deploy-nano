# Invoke-ConfigPwsh.ps1
# Initial config of pwsh on Ubuntu
try {
    $ErrorActionPreference = 'Stop'
    if (Get-Module -ListAvailable PowerShellGet) {
        Import-Module Microsoft.PowerShell.PSResourceGet
        Set-PSResourceRepository -Name PSGallery -Trusted
    }
    if (Get-Module -ListAvailable PowerShellGet) {
        Import-Module PowerShellGet
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    }
    Install-PSResource -Name PSReadLine, Az.Accounts, Az.Tools.Predictor, Microsoft.PowerShell.PSResourceGet, WozTools -Reinstall -Scope AllUsers -PassThru
}
catch {
    throw $_
}
