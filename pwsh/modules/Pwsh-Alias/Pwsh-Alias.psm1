if (Test-Path env:PWSH_TIME -ErrorAction SilentlyContinue) {
    $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
}

function global:vit() {
    nvim "+Git"
}

function global:vnote() {
    if (-not (Test-Path env:ZNOTES_GIT_DIR)) {
        Write-Host -ForegroundColor red "ZNOTES_GIT_DIR environment variable is reuired."
        return
    }

    if (-not (Test-Path env:ZNOTES_DIR)) {
        Write-Host -ForegroundColor red "ZNOTES_DIR environment variable is reuired."
        return
    }

    if (-not (Test-Path $env:ZNOTES_DIR/.nvimrc)) {
        Write-Host -ForegroundColor red "$env:ZNOTES_DIR/.nvimrc file doesn't exist."
        return
    }

    nvim -S $env:ZNOTES_DIR/.nvimrc "+ZkBrowse"
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
