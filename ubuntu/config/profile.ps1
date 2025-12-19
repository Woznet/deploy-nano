$FormatEnumerationLimit = -1

if (-not ($env:GHRUNNING)) {
    $PSDefaultParameterValues.Add('Update-Help:UICulture', 'en-US')
    $PSDefaultParameterValues.Add('Update-Help:Force', $true)
    try {
        Import-Module -Global Az.Tools.Predictor -ErrorAction Stop
    }
    catch {
        Write-Warning 'Az.Tools.Predictor could not be imported'
    }

    try {
        if (-not (Get-Module PSReadLine)) { Import-Module -Global PSReadLine}
    }
    catch {
        Write-Error -ErrorRecord $_;
    }

    $Params = @{
        EditMode = 'Windows';
        ShowToolTips = $true;
        ContinuationPrompt = '  ';
        BellStyle = 'Visual';
        PredictionViewStyle = 'ListView';
        HistorySearchCursorMovesToEnd = $true;
        HistorySaveStyl = 'SaveIncrementally';
        PredictionSource = 'HistoryAndPlugin';
    }

    Set-PSReadLineOption @Params;

    Remove-PSReadLineKeyHandler -Chord 'Shift+Tab';
    Set-PSReadLineKeyHandler -Function MenuComplete -Chord 'Shift+Tab';

    function Get-ShortPath {
        [CmdletBinding()]
        [Alias('GetShortPath')]
        [OutputType([string])]
        param(
            [Parameter(ValueFromPipeline)]
            [ValidateScript({
                    if (-not (Test-Path $_ -PathType Container)) {
                        throw ('{0} - Invalid Directory Path' -f $_)
                    }
                    $true
                })]
            [string]$Path = $PWD.Path
        )
        process {
            $Path = Convert-Path $Path
            $Platform = [System.Environment]::OSVersion.Platform
            $IsWinOS = $Platform -eq [PlatformID]::Win32NT
            $MaxLen = if ($Host.UI.RawUI.BufferSize.Width) {[int]($Host.UI.RawUI.BufferSize.Width / 4)} else {48}
            $DSC = [System.IO.Path]::DirectorySeparatorChar
            $CurrPath = if ($Path -like '*::*') {$Path.Substring($Path.IndexOf('::') + 2).TrimEnd($DSC)} else {$Path.TrimEnd($DSC)}
            if ($CurrPath.Length -le ($MaxLen + 4)) {
                return $CurrPath;
            }
            else {
                $Parts = $CurrPath -split [regex]::Escape($DSC)
                $Parts = $CurrPath.Split($DSC, [System.StringSplitOptions]::RemoveEmptyEntries)
                if ($IsWinOS) {
                    $Prefix = $Parts[0];
                    $Budget = $MaxLen - ($Prefix.Length + 3);
                }
                else {
                    $Budget = $MaxLen - ($Prefix.Length + 1);
                }
                $Suffix = [System.Text.StringBuilder]::new()

                for ($i = $Parts.Length - 1; $i -gt 0; $i--) {
                    $Segment = $Parts[$i]
                    if ($Suffix.Length + $Segment.Length + 1 -gt $Budget) {
                        if ($Suffix.Length -eq 0) {
                            $null = $Suffix.Insert(0, ('{0}{1}' -f $DSC, $Segment))
                        }
                        break
                    }
                    $null = $Suffix.Insert(0, ('{0}{1}' -f $DSC, $Segment))
                }
                return ('{0}{1}{2}{3}{4}' -f $Prefix, $DSC, [char]0x2026, $Suffix.ToString(), $DSC);
            }
        }
    }
    try {
        $RunColorsPath = [System.IO.Path]::Combine($PSScriptRoot, 'runtime-colors.txt')
        $RCList = (Get-Content -Raw $RunColorsPath -ErrorAction Stop).Split(',')
    }
    catch {
        Write-Warning ('Unable to load runtime colors from "{0}"' -f $RunColorsPath)
        $RunColorsUrl = 'https://gist.githubusercontent.com/Woznet/468915d9d3fafde75f64f0442a74085c/raw/9846a0a122bd63e45a6d55c5efa003a30756f1a5/runtime-colors.txt'
        $RCList = (Invoke-RestMethod -Uri $RunColorsUrl).Split(',')
        try {
            ($RCList -join ',') | Out-File -FilePath $RunColorsPath -Encoding utf8NoBOM -ErrorAction Stop
        }
        catch {
            Write-Warning ('Unable to save runtime colors to "{0}"' -f $RunColorsPath)
        }
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

            return $SB.ToString();
        }
        catch {
            Write-Error -ErrorRecord $_;
            return ('PS {0}{1} ' -f $ExecutionContext.SessionState.Path.CurrentLocation, ('>' * ($NestedPromptLevel + 1)));
        }
    }
}
