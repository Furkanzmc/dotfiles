if (Test-Path env:PWSH_TIME -ErrorAction SilentlyContinue) {
    $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
}

if (Test-Path env:NVIM_LISTEN_ADDRESS -ErrorAction SilentlyContinue) {
    if (-not (Get-Command "nvr" -ErrorAction SilentlyContinue)) {
        Write-Host -ForegroundColor Blue "[dotfiles] neovim-remote is not installed."
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

    function Nvim-Open-Current() {
        Param(
            [Parameter(Position=0, Mandatory=$true)]
            [String[]]
            $Paths
        )

        Nvim-Open-Remote -Paths $Paths -Mode Current
    }

    function Nvim-Run-Command() {
        Param(
            [Parameter(Position=0, Mandatory=$true)]
            [String]
            $Command,
            [Parameter(Mandatory=$false)]
            [ValidateSet("Current", "All")]
            [String]
            $Mode="Current"
        )

        if ($Mode -eq "Current") {
            nvr -cc $Command --servername $env:NVIM_LISTEN_ADDRESS -s
        }
        elseif ($Mode -eq "All") {
            $arg = $HOME + '/.dotfiles/scripts/nvim.py --command "' + $Command + '"'
            Start-Process -NoNewWindow -Wait -FilePath python3 -ArgumentList $arg
        }
    }

    Set-Alias -Name nvim -Value Nvim-Open-Current
    Set-Alias -Name nvc -Value Nvim-Run-Command
}

function Codi() {
    Param(
        [Parameter(Mandatory=$false)]
        [ValidateSet("python", "javascript")]
        [String]$FileType=""
     )

    nvim -c `
    "packadd codi.vim `
    let g:startify_disable_at_vimenter = 1 |`
    setlocal cursorline |`
    Codi $FileType"
 }

if (Test-Path env:PWSH_TIME -ErrorAction SilentlyContinue) {
    Write-Host "Loaded Pwsh-Vim in $($Stopwatch.Elapsed.TotalSeconds) seconds."
    $Stopwatch.Stop()
}
