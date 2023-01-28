<#
    Windows deployment script for nano with syntax highlighting files.

    This script will 
    - deploy nanorc syntax files located - https://github.com/galenguyer/nano-syntax-highlighting
    - install latest version of nano-win
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

# Load AngleSharp.dll
try {
  switch ($PSVersionTable.PSEdition) {
    'Core' {
      $null = [System.Reflection.Assembly]::LoadFile((Join-Path -Path $PSScriptRoot -ChildPath 'lib\Core\AngleSharp.dll' -Resolve))
    }
    'Desktop' {
      $null = [System.Reflection.Assembly]::LoadFile((Join-Path -Path $PSScriptRoot -ChildPath 'lib\Desktop\System.Text.Encoding.CodePages.dll' -Resolve))
      $null = [System.Reflection.Assembly]::LoadFile((Join-Path -Path $PSScriptRoot -ChildPath 'lib\Desktop\AngleSharp.dll' -Resolve))
    }
    default { throw 'Something went wrong!' }
  }
}
catch {
  [System.Management.Automation.ErrorRecord]$e = $_
  [PSCustomObject]@{
    Type      = $e.Exception.GetType().FullName
    Exception = $e.Exception.Message
    Reason    = $e.CategoryInfo.Reason
    Target    = $e.CategoryInfo.TargetName
    Script    = $e.InvocationInfo.ScriptName
    Line      = $e.InvocationInfo.ScriptLineNumber
    Column    = $e.InvocationInfo.OffsetInLine
  }
  throw $_
}

# Download latest nano-win version
try {
  $Content = (Invoke-WebRequest -Uri 'https://files.lhmouse.com/nano-win/').Content
  $HTMLParser = [AngleSharp.Html.Parser.HtmlParser]::new()
  $ParsedDocument = $HTMLParser.ParseDocument($Content)
  $Link = $ParsedDocument.Links.PathName -match 'nano-win*' | Select-Object -First 1

  $NWurl = Join-Url -Base https://files.lhmouse.com/nano-win/ -Child $Link.TrimStart('/')
  $NWSavePath = Join-Path -Path $env:TEMP -ChildPath (Split-Path -Path $NWurl -Leaf)
  $WC = [System.Net.WebClient]::new()
  $WC.DownloadFile($NWurl, $NWSavePath)
  $WC.Dispose()
}
catch {
  [System.Management.Automation.ErrorRecord]$e = $_
  [PSCustomObject]@{
    Type      = $e.Exception.GetType().FullName
    Exception = $e.Exception.Message
    Reason    = $e.CategoryInfo.Reason
    Target    = $e.CategoryInfo.TargetName
    Script    = $e.InvocationInfo.ScriptName
    Line      = $e.InvocationInfo.ScriptLineNumber
    Column    = $e.InvocationInfo.OffsetInLine
  }
  throw $_
}

# extract 7z archive
$TMPNanowin = Join-Path -Path $env:TEMP -ChildPath 'nano-win'
7z x -o"$TMPNanowin" $NWSavePath
# copy nano.exe to install folder
$NanoExe = Join-Path -Path $TMPNanowin -ChildPath 'pkg_x86_64-w64-mingw32\bin\nano.exe' -Resolve
Get-Item -Path $NanoExe | Copy-Item -Destination 'C:\ProgramData\nano-win'
# save nanorc file to ProgramData folder
Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/Woznet/deploy-nano-win/main/windows/nano/nanorc' | Out-File -FilePath C:\ProgramData\nanorc
# Add nano.exe directory to PATH
Add-EnvPath -VariableTarget Machine -Path 'C:\ProgramData\nano-win'
# refresh powershell environment
Update-SessionEnvironment


