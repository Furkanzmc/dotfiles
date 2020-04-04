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
}

if (Test-Path env:PWSH_TIME -ErrorAction SilentlyContinue) {
    Write-Host "Loaded Pwsh-Alias in $($Stopwatch.Elapsed.TotalSeconds) seconds."
    $Stopwatch.Stop()
}
