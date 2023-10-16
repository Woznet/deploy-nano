<#
    Windows deployment script for nano with syntax highlighting files.

    This script will 
    - deploy nanorc syntax files located - https://github.com/galenguyer/nano-syntax-highlighting
    - install latest version of nano-win
    
    Join-Url and Add-EnvPath - are from WozTools - https://github.com/Woznet/WozTools
    Update-SessionEnvironment - is part of chocolatey - 
    https://github.com/chocolatey/choco/blob/develop/src/chocolatey.resources/helpers/functions/Update-SessionEnvironment.ps1
#>

### Download nano syntax files
$NanoSyntaxDir = 'C:\ProgramData\nano-win\nano-syntax'
# clone repo
git clone https://github.com/galenguyer/nano-syntax-highlighting $NanoSyntaxDir
# Fix broken symlink files
New-Item -ItemType SymbolicLink  -Path "$NanoSyntaxDir/gitcommit.nanorc" -Value "$NanoSyntaxDir/git.nanorc" -Force
New-Item -ItemType SymbolicLink  -Path "$NanoSyntaxDir/html.j2.nanorc" -Value "$NanoSyntaxDir/html.nanorc" -Force
New-Item -ItemType SymbolicLink  -Path "$NanoSyntaxDir/twig.nanorc" -Value "$NanoSyntaxDir/html.nanorc" -Force
New-Item -ItemType SymbolicLink  -Path "$NanoSyntaxDir/zshrc.nanorc" -Value "$NanoSyntaxDir/zsh.nanorc" -Force

# Find nano-win latest release
$BaseUrl = 'https://files.lhmouse.com/nano-win/'
$IRM = Invoke-RestMethod -Uri $BaseUrl
$NanoFile = ($IRM.Split('><') | ? {$_ -like '*"nano-win*v7*.7z"*'})[0].Split(' ')[1].Split('"')[1]

$NWurl = Join-Url -Base $BaseUrl -Child $NanoFile
$NWSavePath = Join-Path -Path $env:TEMP -ChildPath $NanoFile
$WC = [System.Net.WebClient]::new()
$WC.DownloadFile($NWurl, $NWSavePath)
$WC.Dispose()

# extract 7z archive
$TMPNanowin = Join-Path -Path $env:TEMP -ChildPath 'nano-win'
7z x -o"$TMPNanowin" $NWSavePath
# copy nano.exe to install folder
$NanoExe = Join-Path -Path $TMPNanowin -ChildPath 'pkg_x86_64-w64-mingw32\bin\nano.exe' -Resolve
Get-Item -Path $NanoExe | Copy-Item -Destination 'C:\ProgramData\nano-win'
# save nanorc file to ProgramData folder
Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/Woznet/deploy-nano/main/windows/nanorc' | Out-File -FilePath C:\ProgramData\nanorc
# Add nano.exe directory to PATH
Add-EnvPath -VariableTarget Machine -Path 'C:\ProgramData\nano-win'
# refresh powershell environment
Update-SessionEnvironment



