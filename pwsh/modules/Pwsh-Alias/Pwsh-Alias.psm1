if (Test-Path env:PWSH_TIME -ErrorAction SilentlyContinue) {
    $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
}

if (Get-Command "fd" -ErrorAction SilentlyContinue) {
    Set-Alias find fd
}

if (Get-Command "exa" -ErrorAction SilentlyContinue) {
    Set-Alias ls exa
}

if (Get-Command "bat" -ErrorAction SilentlyContinue) {
    Set-Alias cat bat
}

if (Get-Command "nvim" -ErrorAction SilentlyContinue) {
    Set-Alias vim nvim
    $env:MANPAGER="nvim +Man!"
}

if (Get-Command "rmtrash" -ErrorAction SilentlyContinue) {
    Set-Alias trash rmtrash
}

if (Get-Command "Source-Env" -ErrorAction SilentlyContinue) {
    Set-Alias -Value Source-Env -Name :
}

if (Get-Command "fcp" -ErrorAction SilentlyContinue) {
    Set-Alias cp fcp
}

function Pwsh-Exit() {
    exit
}

Set-Alias -Name :e -Value nvim
Set-Alias -Name :q -Value Pwsh-Exit

if (Test-Path env:PWSH_TIME -ErrorAction SilentlyContinue) {
    Write-Host "Loaded Pwsh-Alias in $($Stopwatch.Elapsed.TotalSeconds) seconds."
    $Stopwatch.Stop()
}
