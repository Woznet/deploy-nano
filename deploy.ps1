<#
    ---- WIP ----

    Deployment script for nanorc config file, nanorc syntax highlighting files.
    For Windows computers, this will also downloaded and install nano-win if nano is not located in PATH


    This script will deploy nanorc syntax files located in this repo - https://github.com/Woznet/deploy-nano-win
    nanorc files were sourced from - https://github.com/galenguyer/nano-syntax-highlighting

    The script will also install latest version of nano-win
    nano-win will either be save as a 7z file in the repo, or
    downloaded directly from the nano-win release site - https://files.lhmouse.com/nano-win/


#>


$NanoSyntaxRepo = 'https://github.com/Woznet/deploy-nano-win/archive/master.zip'
$SavePath = Join-Path -Path $env:TEMP -ChildPath (Split-Path -Path $NanoSyntaxRepo -Leaf)

$WC = [System.Net.WebClient]::new()
$WC.DownloadFile($NanoSyntaxRepo, $SavePath)
$WC.Dispose()

7z -o"$env:TEMP" $SavePath


$nanorcsyntax = @'
### github syntax definitions from
include "{0}"

###
'@

$NRCFile = Get-Item -Path $env:TEMP\deploy-nano-win\nano\nanorc

switch ([environment]::OSVersion.Platform) {
  Win32NT {
    ($nanorcsyntax -f 'C:/ProgramData/nano-win/nanorc-syntax/*.nanorc') | Add-Content -Path $NRCFile
    Get-Item -Path $NRCFile | Move-Item -Destination 'C:/ProgramData/nanorc' -Force -PassThru
    break
  }
  Unix {
    ($nanorcsyntax -f '/usr/share/nano/*.nanorc') | Add-Content -Path $NRCFile
    Get-Item -Path $NRCFile | Move-Item -Destination '/etc/nanorc' -Force -PassThru
    break
  }
  default {
    throw 'something went wrong'
  }
}



##### WINDOWS ONLY #####
New-Item -ItemType Directory -Path 'C:\ProgramData\nano-win\nanorc-syntax' -Force
Get-Item -Path $env:TEMP\deploy-nano-win\nano\nano-syntax-highlighting-master\*.nanorc | Move-Item -Destination 'C:\ProgramData\nano-win\nanorc-syntax'

New-Item -ItemType SymbolicLink  -Path 'C:/ProgramData/nano-win/nanorc-syntax/gitcommit.nanorc' -Value 'C:/ProgramData/nano-win/nanorc-syntax/git.nanorc' -Force
New-Item -ItemType SymbolicLink  -Path 'C:/ProgramData/nano-win/nanorc-syntax/html.j2.nanorc' -Value 'C:/ProgramData/nano-win/nanorc-syntax/html.nanorc' -Force
New-Item -ItemType SymbolicLink  -Path 'C:/ProgramData/nano-win/nanorc-syntax/twig.nanorc' -Value 'C:/ProgramData/nano-win/nanorc-syntax/html.nanorc' -Force
New-Item -ItemType SymbolicLink  -Path 'C:/ProgramData/nano-win/nanorc-syntax/zshrc.nanorc' -Value 'C:/ProgramData/nano-win/nanorc-syntax/zsh.nanorc' -Force





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
  
  $TMPNanowin = Join-Path -Path $env:TEMP -ChildPath 'nano-win'
  
  7z x -o"$TMPNanowin" $NWSavePath
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

# "\pkg_x86_64-w64-mingw32\bin\nano.exe"

#### TO DO ####
## SAVE extracted nano-win to folder - maybe 'C:\Program Files\nano' - or C:\ProgramData\nano-win
$NanoExe = Join-Path -Path $TMPNanowin -ChildPath 'pkg_x86_64-w64-mingw32\bin\nano.exe' -Resolve
Get-Item -Path $NanoExe | Copy-Item -Destination 'C:\ProgramData\nano-win'

Add-EnvPath -VariableTarget Machine -Path 'C:\ProgramData\nano-win'

