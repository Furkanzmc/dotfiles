if (Test-Path env:PWSH_TIME -ErrorAction SilentlyContinue) {
    $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
}

function global:vit() {
    nvim "+Git"
}

function global:vnote() {
    nvim "+ZkBrowse"
}

function Pwsh-Exit() {
    exit
}

Set-Alias -Name :e -Value nvim
Set-Alias -Name :q -Value Pwsh-Exit
Set-Alias find fd

Set-Alias vim nvim
Set-Alias -Value Source-Env -Name :

$env:MANPAGER="nvim -U NORC +Man!"
if ($IsMacOS) {
    Set-Alias trash rmtrash
    Set-Alias ls exa
    Set-Alias cat bat
}

if ($IsWindows) {
    Set-Alias wc Measure-Object
}

if (Test-Path env:PWSH_TIME -ErrorAction SilentlyContinue) {
    Write-Host "Loaded Pwsh-Alias in $($Stopwatch.Elapsed.TotalSeconds) seconds."
    $Stopwatch.Stop()
}
