if (Test-Path env:PWSH_TIME -ErrorAction SilentlyContinue) {
    $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
}

if (-not (Test-Path env:NVIM_LISTEN_ADDRESS -ErrorAction SilentlyContinue)) {
    return
}

if (-not (Get-Command "nvr" -ErrorAction SilentlyContinue)) {
    Write-Error "Install neovim-remote"
    return
}

function Nvim-Open-Remote() {
    Param(
        [Parameter(Position=0, Mandatory=$true)]
        [String[]]
        $Paths,
        [Parameter(Position=0, Mandatory=$true)]
        [ValidateSet("Vertical", "Horizontal", "Tab", "Current")]
        [String]
        $Mode
    )

    if ($Mode -eq "Vertical") {
        nvr -O $Paths
    }
    elseif ($Mode -eq "Horizontal") {
        nvr -o $Paths
    }
    elseif ($Mode -eq "Tab") {
        nvr --remote-tab $Paths
    }
    elseif ($Mode -eq "Current") {
        nvr -l $Paths
    }
}

function Nvim-Open-Vertical() {
    Param(
        [Parameter(Position=0, Mandatory=$true)]
        [String[]]
        $Paths
    )

    Nvim-Open-Remote -Paths $Path -Mode Vertical
}

function Nvim-Open-Horizontal() {
    Param(
        [Parameter(Position=0, Mandatory=$true)]
        [String[]]
        $Paths
    )

    Nvim-Open-Remote -Paths $Paths -Mode Horizontal
}

function Nvim-Open-Tab() {
    Param(
        [Parameter(Position=0, Mandatory=$true)]
        [String[]]
        $Paths
    )

    Nvim-Open-Remote -Paths $Paths -Mode Tab
}

function Nvim-Open-Current() {
    Param(
        [Parameter(Position=0, Mandatory=$true)]
        [String[]]
        $Paths
    )

    Nvim-Open-Remote -Paths $Paths -Mode Current
}

Set-Alias -Name nvmh -Value Nvim-Open-Horizontal
Set-Alias -Name nvmv -Value Nvim-Open-Vertical
Set-Alias -Name nvmt -Value Nvim-Open-Tab
Set-Alias -Name nvim -Value Nvim-Open-Current

if (Test-Path env:PWSH_TIME -ErrorAction SilentlyContinue) {
    Write-Host "Loaded Pwsh-Vim in $($Stopwatch.Elapsed.TotalSeconds) seconds."
    $Stopwatch.Stop()
}
