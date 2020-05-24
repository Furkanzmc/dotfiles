# Prompt takes care of this.
$env:VIRTUAL_ENV_DISABLE_PROMPT=1
if ((Test-Path env:VIRTUAL_ENV) -and (Test-Path "${env:VIRTUAL_ENV}/bin/activate.ps1")) {
    . ${env:VIRTUAL_ENV}/bin/activate.ps1
}

if ($IsWindows) {
    $env:PSModulePath += ";~/.dotfiles/pwsh/modules/"
}
else {
    $env:PSModulePath += ":~/.dotfiles/pwsh/modules/"
}

if (Test-Path env:PWSH_TIME -ErrorAction SilentlyContinue) {
    $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $MainStopwatch = [System.Diagnostics.Stopwatch]::StartNew()
}

Import-Module Pwsh-DotEnv -DisableNameChecking
Import-Module Pwsh-Vim -DisableNameChecking
Import-Module Pwsh-Completion -DisableNameChecking
if ($IsMacOS) {
    Import-Module Pwsh-MacOS -DisableNameChecking
}
else {
    Import-Module Pwsh-Windows -DisableNameChecking
}

Import-Module Pwsh-Utils -DisableNameChecking
Import-Module Pwsh-Alias -DisableNameChecking

if (Test-Path env:PWSH_TIME -ErrorAction SilentlyContinue) {
    Write-Host "Loaded all custom modules in $($Stopwatch.Elapsed.TotalSeconds) seconds."
    $Stopwatch.Stop()
}

if (Test-Path env:PWSH_TIME -ErrorAction SilentlyContinue) {
    $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
}

Import-Module PSReadLine
$PSReadLineOptions = @{
    EditMode = "Vi"
    HistoryNoDuplicates = $true
    HistorySearchCursorMovesToEnd = $true
    HistorySaveStyle = "SaveIncrementally"
    ViModeIndicator = "Cursor"
    Colors = @{
        # cosmic-latte colors
        "Error" = "#202a31"
        "String" = "#7d9761"
        "Command" = "#8181f7"
        "Comment" = "#898f9e"
        "Operator" = "#459d90"
        "Number" = "#5496bd"
    }
}

Set-PSReadLineOption @PSReadLineOptions
if (Test-Path env:PWSH_TIME -ErrorAction SilentlyContinue) {
    Write-Host "Loaded all external modules in $($Stopwatch.Elapsed.TotalSeconds) seconds."
    $Stopwatch.Stop()
}

function Prompt() {
    $lastCommandSucceeded = $?
    $exitCode = $LastExitCode
    if (Test-Path env:VIRTUAL_ENV -ErrorAction SilentlyContinue) {
        Write-Host "(.venv) " -ForegroundColor Yellow -NoNewLine
    }

    $currentLocation = $(Get-Location).Path
    if ($IsMacOS) {
        $currentLocation = $currentLocation.Replace($env:HOME, "~")
    }
    else {
        $currentLocation = $currentLocation.Replace($env:USERPROFILE, "~")
    }
    $maxWidth = 80

    if ($currentLocation.Length -gt $maxWidth) {
        $p1 = $currentLocation.Substring(0, $currentLocation.IndexOf("/", 2) + 1)
        $lastSlash = $currentLocation.IndexOf("/", $maxWidth + $p1.Length)
        $currentLocation = $p1 + "..." + $currentLocation.Substring($lastSlash)
    }

    Write-Host "$currentLocation " -NoNewLine -ForegroundColor Blue

    $gitDir = &git rev-parse --git-dir
    # Continue if the command succeeded.
    if ($?) {
        $branchName = Get-Content ( `
                Join-Path $gitDir -ChildPath HEAD `
                )
        $branchName = $branchName.Replace("ref: ", "")
        $branchName = $branchName.Replace("refs/heads/", "")

        # Check for an active rebase.
        $rebaseMergePath = Join-Path $gitDir -ChildPath rebase-merge
        $rebasing = Test-Path -Path $rebaseMergePath
        if ($rebasing) {
            Write-Host "[$branchName" -ForegroundColor Green -NoNewLine
            Write-Host ":" -ForegroundColor Green -NoNewLine
            $isInteractiveRebase = Test-Path -Path (`
                    Join-Path $rebaseMergePath -ChildPath interactive `
                    )
            if ($isInteractiveRebase) {
                Write-Host "REBASE-I" -ForegroundColor Blue -NoNewLine
            }
            else {
                Write-Host "REBASE-M" -ForegroundColor Blue -NoNewLine
            }

            Write-Host "] " -ForegroundColor Green -NoNewLine
        }
        else {
            Write-Host "[$branchName] " -ForegroundColor Green -NoNewLine
        }
    }

    Write-Host $(Get-Date -Format "[HH:mm:ss]") `
        -ForegroundColor DarkGray -NoNewLine

    if ($lastCommandSucceeded -eq $false) {
        $bufferSize = (Get-Host).UI.RawUI.BufferSize.Width
        Write-Host " !! $exitCode" -NoNewLine -ForegroundColor Red
    }

    Write-Host "`n$("=>" * ($NestedPromptLevel + 1))" -NoNewLine -ForegroundColor Green
    return " "
}

if (Test-Path env:PWSH_TIME -ErrorAction SilentlyContinue) {
    Write-Host "Loaded PowerShell config in $($MainStopwatch.Elapsed.TotalSeconds) seconds."
    $MainStopwatch.Stop()
}
