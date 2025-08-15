# Invoke-ConfigPwsh.ps1
# Initial config of pwsh on Ubuntu
try {
    $ErrorActionPreference = 'Stop'
    if (Get-Module -ListAvailable Microsoft.PowerShell.PSResourceGet -ErrorAction SilentlyContinue) {
        Import-Module Microsoft.PowerShell.PSResourceGet
        Set-PSResourceRepository -Name PSGallery -Trusted
    }
    if (Get-Module -ListAvailable PowerShellGet -ErrorAction SilentlyContinue) {
        Import-Module PowerShellGet
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    }
    Install-PSResource -Name PSReadLine, Az.Accounts, Az.Tools.Predictor, Microsoft.PowerShell.PSResourceGet, WozTools -Reinstall -Scope AllUsers -PassThru
    Update-Help -UICulture ([cultureinfo]::CurrentUICulture) -Module * -Force
    $Csv1 = (getent passwd) | ConvertFrom-Csv -Delimiter ':' -Header User, X, UserID, GroupID, Name, Home, App;
    $InvUser = $Csv1 | Where-Object {$_.UserID -eq $env:SUDO_UID};
    $InvUAH = Join-Path $InvUser.Home '.config/powershell/profile.ps1';
    $InvUCH = Join-Path $InvUser.Home '.config/powershell/Microsoft.PowerShell_profile.ps1';

    @(
        $PROFILE.AllUsersAllHosts,
        $PROFILE.AllUsersCurrentHost,
        $PROFILE.CurrentUserAllHosts,
        $PROFILE.CurrentUserCurrentHost,
        $InvUAH,
        $InvUCH
    ) | Where-Object {(Test-Path $_) -eq $false} | ForEach-Object {$null = New-Item -Path $_ -ItemType File -Force -ErrorAction Continue}
    if (Test-Path $InvUAH) { & chown "$($env:SUDO_USER):$($env:SUDO_USER)" $InvUAH }
    if (Test-Path $InvUCH) { & chown "$($env:SUDO_USER):$($env:SUDO_USER)" $InvUCH }
}
catch {
    throw $_
}
