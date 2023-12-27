$FormatEnumerationLimit = -1

if (-not ($env:GHRUNNING)) {

  Import-Module -Global -Name PSReadLine

  $Params = @{
    EditMode                      = 'Windows'
    ShowToolTips                  = $true
    ContinuationPrompt            = '  '
    BellStyle                     = 'Visual'
    PredictionViewStyle           = 'ListView'
    HistorySearchCursorMovesToEnd = $true
    HistorySaveStyl               = 'SaveIncrementally'
    PredictionSource              = 'HistoryAndPlugin'
  }

  Set-PSReadLineOption @Params

  Remove-PSReadLineKeyHandler -Chord 'Shift+Tab'
  Set-PSReadLineKeyHandler -Function MenuComplete -Chord 'Shift+Tab'

$GetShortPath = {
    if ($null -ne $Host.UI.RawUI.WindowSize.Width) {
        $MaxPromptPath = [int]($Host.UI.RawUI.WindowSize.Width / 3)
        $CurrPath = $PWD.Path -replace '^[^:]+::'
        $DSC = [System.IO.Path]::DirectorySeparatorChar

        if ($CurrPath.Length -ge $MaxPromptPath) {
            $PathParts = $CurrPath.Split($DSC)
            $EndPath = [System.Text.StringBuilder]::new()

            for ($i = $PathParts.Length - 1; $i -gt 0; $i--) {
                $TempPart = $PathParts[$i]
                $TempPath = [System.IO.Path]::Combine($EndPath.ToString(), $TempPart)
                if ($TempPath.Length -lt $MaxPromptPath) {
                    [void]$EndPath.Insert(0, $TempPart + $DSC)
                }
                else {
                    break
                }
            }
            $GSPath = '{0}{1}...{1}{2}' -f $PathParts[0], $DSC, $EndPath.ToString().TrimEnd($DSC)
        }
        else {
            $GSPath = $CurrPath
        }
        return $GSPath
    }
}

  function prompt {
    if ($PWD.Provider.Name -eq 'FileSystem') {
      [Environment]::CurrentDirectory = (Convert-Path -Path '.')
    }
    $History = Get-History -Count 1 -ErrorAction Ignore
    if ($History) {
      $CmdExeTime = switch (New-TimeSpan -Start $History.StartExecutionTime -End $History.EndExecutionTime) {
        { $_.TotalSeconds -lt 1 } { '[{0}ms]' -f [int]$_.TotalMilliseconds ; break }
        { $_.TotalMinutes -lt 1 } { '[{0}s]' -f [int]$_.TotalSeconds ; break }
        { $_.TotalMinutes -ge 1 } { '[{0:HH:mm:ss}]' -f [datetime]$_.Ticks ; break }
      }
    }
    $esc = ([char]27) ; $lcyan = 81 ; $yel = 214 ; $grn = 46 ; $dcyan = 74
    Write-Host -NoNewline (
      (
        '{9}{10}' +
        '{0}[38;5;{4}m{8}{0}[38;5;{2}m{5}{0}[38;5;{3}m{6}' +
        '{0}[38;5;{4}m{{{0}[38;5;{1}m{7}{0}[38;5;{4}m}}{0}[0m'
      ) -f $esc, $lcyan, $yel, $grn, $dcyan,
      ('{0}{1}{2}' -f ([char]0xAB), ([DateTime]::Now.ToShortTimeString()), ([char]0xBB)),
      [System.Net.Dns]::GetHostName(), $GetShortPath.Invoke().Trim(), ([char]0xA7),
      $CmdExeTime, "`n"
    )
    return '> '
  }
}
