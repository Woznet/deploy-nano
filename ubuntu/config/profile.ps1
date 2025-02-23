$FormatEnumerationLimit = -1

if (-not ($env:GHRUNNING)) {
    Import-Module -Global PSReadLine
    Import-Module -Global Az.Tools.Predictor

    $Params = @{
        EditMode = 'Windows'
        ShowToolTips = $true
        ContinuationPrompt = '  '
        BellStyle = 'Visual'
        PredictionViewStyle = 'ListView'
        HistorySearchCursorMovesToEnd = $true
        HistorySaveStyl = 'SaveIncrementally'
        PredictionSource = 'HistoryAndPlugin'
    }

    Set-PSReadLineOption @Params

    Remove-PSReadLineKeyHandler -Chord 'Shift+Tab'
    Set-PSReadLineKeyHandler -Function MenuComplete -Chord 'Shift+Tab'

    function GetShortPath {
        [CmdletBinding()]
        param(
            [ValidateScript({
                    if (-not ($_ | Test-Path -IsValid -PathType Container)) {
                        throw ('{0} - Invalid Directory Path' -f $_)
                    }
                    return $true
                })]
            [Parameter(ValueFromPipeline)]
            [string]$Path = $PWD.Path
        )
        process {
            if ($Host.UI.RawUI.BufferSize.Width) {
                $MaxPromptPath = [int]($Host.UI.RawUI.BufferSize.Width / 3)
            }
            else {
                $MaxPromptPath = 48
            }
            $CurrPath = $Path -replace '^[^:]+::'
            $DSC = [System.IO.Path]::DirectorySeparatorChar

            if ($CurrPath.Length -gt ($MaxPromptPath + 4)) {
                $PathParts = $CurrPath.Split($DSC)
                $EndPath = [System.Text.StringBuilder]::new()
                $ShortPath = [System.Text.StringBuilder]::new()

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
                $null = $ShortPath.Append($PathParts[0])
                $null = $ShortPath.Append($DSC)
                $null = $ShortPath.Append([char]::ConvertFromUtf32(8230))
                $null = $ShortPath.Append($DSC)
                $null = $ShortPath.Append($EndPath.ToString().TrimEnd($DSC))
                $GSPath = $ShortPath.ToString()
            }
            else {
                $GSPath = $CurrPath
            }
            return $GSPath
        }
    }
    try {
        $RunColorsPath = Join-Path $PSScriptRoot 'runtime-colors.txt' -Resolve -ErrorAction Stop
        $RCList = (Get-Content -Raw $RunColorsPath -ErrorAction Stop).Split(',')
    }
    catch {
        Write-Warning ('Unable to load runtime colors from "{0}"' -f $RunColorsPath)
        $RunColorsUrl = 'https://gist.githubusercontent.com/Woznet/468915d9d3fafde75f64f0442a74085c/raw/32149b346123813f82434a814bad43f7a6d98340/runtime-colors.txt'
        $RCList = (Invoke-RestMethod -Uri $RunColorsUrl).Split(',')
    }
    finally {
        Remove-Variable RunColorsPath, RunColorsUrl -Force -ErrorAction Ignore
    }

    function prompt {
        try {
            if ($PWD.Provider.Name -eq 'FileSystem') {
                [Environment]::CurrentDirectory = $PWD.ProviderPath
            }

            $Time = '{0}{1}{2}' -f ([char]0xAB), ([DateTime]::Now.ToShortTimeString()), ([char]0xBB)
            $HostName = [System.Net.Dns]::GetHostName()
            $SB = [System.Text.StringBuilder]::new()
            $ShortPath = GetShortPath
            $History = Get-History -Count 1 -ErrorAction Ignore
            if ($History) {
                if ($History.Duration) {
                    $TimeSpan = $History.Duration
                }
                else {
                    $TimeSpan = New-TimeSpan -Start $History.StartExecutionTime -End $History.EndExecutionTime
                }
                $CmdExeTime = switch ($TimeSpan) {
                    { $_.TotalSeconds -lt 1 } { '[{0}ms]' -f [int]$_.TotalMilliseconds ; break }
                    { $_.TotalMinutes -lt 3 } { '[{0}s]' -f [int]$_.TotalSeconds ; break }
                    { $_.TotalMinutes -ge 3 } { '[{0:HH:mm:ss}]' -f [datetime]$_.Ticks ; break }
                }
            }

            $esc = ([char]27) ; $lcyan = 81 ; $yel = 214 ; $grn = 46 ; $dcyan = 74
            $AsciBase = '{0}[38;5;{1}m' ; $EndAsci = '{0}[0m' -f $esc
            ### Prompt - Start
            if ($History) {
                $null = $SB.Append('{0} ' -f $History.Id)
                if ($RCList) {
                    $null = $SB.Append(('{0}[38;2;{1}m' -f $esc, $RCList.GetValue([int]$TimeSpan.TotalSeconds)))
                }
                $null = $SB.Append($CmdExeTime)
                $null = $SB.Append($EndAsci)
                $null = $SB.AppendLine()
            }
            ### Prompt - Next Line
            $null = $SB.Append(($AsciBase -f $esc, $dcyan))
            $null = $SB.Append(([char]0xA7))
            $null = $SB.Append(($AsciBase -f $esc, $yel))
            $null = $SB.Append($Time)
            $null = $SB.Append(($AsciBase -f $esc, $grn))
            $null = $SB.Append($HostName)
            $null = $SB.Append(($AsciBase -f $esc, $dcyan))
            $null = $SB.Append('{')
            $null = $SB.Append(($AsciBase -f $esc, $lcyan))
            $null = $SB.Append($ShortPath)
            $null = $SB.Append(($AsciBase -f $esc, $dcyan))
            $null = $SB.Append('}')
            $null = $SB.Append($EndAsci)
            $null = $SB.Append(('{0} ' -f ('>' * ($NestedPromptLevel + 1))))
            ### Prompt - End

            return $SB.ToString()
        }
        catch {
            'PS {0}{1} ' -f $ExecutionContext.SessionState.Path.CurrentLocation, ('>' * ($NestedPromptLevel + 1));
        }
    }
}
