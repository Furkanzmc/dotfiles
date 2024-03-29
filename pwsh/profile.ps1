﻿# Prompt takes care of this.
$env:VIRTUAL_ENV_DISABLE_PROMPT=1
if ((Test-Path env:VIRTUAL_ENV) -and (Test-Path "${env:VIRTUAL_ENV}/bin/activate.ps1")) {
    . ${env:VIRTUAL_ENV}/bin/activate.ps1
}

$PSStyle.OutputRendering = [System.Management.Automation.OutputRendering]::PlainText;

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
}

Set-PSReadLineOption @PSReadLineOptions
if (Test-Path env:PWSH_TIME -ErrorAction SilentlyContinue) {
    Write-Host "Loaded all external modules in $($Stopwatch.Elapsed.TotalSeconds) seconds."
    $Stopwatch.Stop()
}

Import-Module Pwsh-Prompt -DisableNameChecking
function Prompt() {
    $prevCommandOK = $?
    $exitCode = $LastExitCode
    Source-Local-Profile
    Write-Prompt -LastCommandSucceeded $prevCommandOK -ExitCode $exitCode
    return " "
}

Set-PSReadLineKeyHandler -Chord "Ctrl+n" -Function TabCompleteNext
Set-PSReadLineKeyHandler -Chord "Ctrl+p" -Function TabCompletePrevious
Set-PSReadLineKeyHandler -Chord "Ctrl+w" -Function BackwardDeleteWord
Set-PSReadLineKeyHandler -Chord "Ctrl+j" -Function AcceptLine
Set-PSReadLineKeyHandler -Chord "Ctrl+h" -Function BackwardDeleteChar
Set-PSReadLineKeyHandler -Chord "Shift+Tab" -Function AcceptSuggestion
Set-PSReadLineKeyHandler -Chord "Tab" -Function AcceptNextSuggestionWord

if (Test-Path env:PWSH_TIME -ErrorAction SilentlyContinue) {
    Write-Host "Loaded PowerShell config in $($MainStopwatch.Elapsed.TotalSeconds) seconds."
    $MainStopwatch.Stop()
}
