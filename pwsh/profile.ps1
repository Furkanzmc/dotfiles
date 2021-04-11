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

function Update-Dotfiles() {
    Push-Location ~/.dotfiles/
    git pull
    Pop-Location
}

Set-PSReadLineOption @PSReadLineOptions
if (Test-Path env:PWSH_TIME -ErrorAction SilentlyContinue) {
    Write-Host "Loaded all external modules in $($Stopwatch.Elapsed.TotalSeconds) seconds."
    $Stopwatch.Stop()
}

Import-Module Pwsh-Prompt -DisableNameChecking
function Prompt() {
    Source-Local-Profile
    Write-Prompt
    return " "
}

if (Test-Path env:PWSH_TIME -ErrorAction SilentlyContinue) {
    Write-Host "Loaded PowerShell config in $($MainStopwatch.Elapsed.TotalSeconds) seconds."
    $MainStopwatch.Stop()
}
