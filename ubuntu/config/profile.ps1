$FormatEnumerationLimit = -1

if (-not ($env:GHRUNNING)) {

  Import-Module -Global PSReadLine

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

  Set-PSReadLineKeyHandler -Function MenuComplete -Chord 'Shift+Tab'

  Remove-PSReadLineKeyHandler -Chord 'Shift+Tab'
  Set-PSReadLineKeyHandler -Function MenuComplete -Chord 'Shift+Tab'

  function prompt {
    [environment]::CurrentDirectory = $PWD.Path
    $History = Get-History -Count 1 -ErrorAction Ignore
    if ($History) {
      $CmdExeTime = switch (New-TimeSpan -Start $History.StartExecutionTime -End $History.EndExecutionTime) {
        # $CmdExeTime = switch ($History.Duration) {
        { $_.TotalSeconds -lt 1 } { '[{0}ms]' -f [int]$_.TotalMilliseconds ; break }
        { $_.TotalMinutes -lt 1 } { '[{0}s]' -f [int]$_.TotalSeconds ; break }
        { $_.TotalMinutes -ge 1 } { '[{0:HH:mm:ss}]' -f [datetime]$_.Ticks ; break }
      }
    }
    if ($psISE) {
      if ($History) {
        Write-Host -ForegroundColor White $CmdExeTime
      }
      Write-Host -NoNewline -ForegroundColor DarkCyan ([char]0xA7)
      Write-Host -NoNewline -ForegroundColor Yellow $Time
      Write-Host -NoNewline -ForegroundColor Green $HostName
      Write-Host -NoNewline -ForegroundColor DarkCyan '{'
      Write-Host -NoNewline -ForegroundColor Cyan $ShortPath
      Write-Host -NoNewline -ForegroundColor DarkCyan '}'
    }
    else {
      $esc = ([char]27) ; $lcyan = 81 ; $yel = 214 ; $grn = 46 ; $dcyan = 74
      Write-Host -NoNewline ((
          '{9}{10}' +
          '{0}[38;5;{4}m{8}{0}[38;5;{2}m{5}{0}[38;5;{3}m{6}' +
          '{0}[38;5;{4}m{{{0}[38;5;{1}m{7}{0}[38;5;{4}m}}{0}[0m'
        ) -f $esc, $lcyan, $yel, $grn, $dcyan,
    ('{0}{1}{2}' -f ([char]0xAB), ([DateTime]::Now.ToShortTimeString()), ([char]0xBB)),
        [System.Net.Dns]::GetHostName(), ($PWD.Path -replace '^[^:]+::'), ([char]0xA7),
        $CmdExeTime, [environment]::NewLine)
    }
    return '> '
  }
}
