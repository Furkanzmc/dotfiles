if (Test-Path env:PWSH_TIME -ErrorAction SilentlyContinue) {
    $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
}

if (Test-Path env:NVIM_LISTEN_ADDRESS -ErrorAction SilentlyContinue) {
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
            $arg = $HOME + '/.vim_runtime/nvim.py --command "' + $Command + '"'
            Start-Process -NoNewWindow -Wait -FilePath python3 -ArgumentList $arg
        }
    }

    Set-Alias -Name nvim -Value Nvim-Open-Current
    Set-Alias -Name nvc -Value Nvim-Run-Command
}

function Vimrc-Background() {
    Param(
            [Parameter(Mandatory=$false)]
            [ValidateSet("light", "dark")]
            [String]$Color="",
            [Parameter(Mandatory=$false)]
            [Bool]$ChangeAllInstances=$false,
            [Parameter(Mandatory=$false)]
            [Bool]$MatchTheme=$false
         )

    if ($MatchTheme) {
        if (Get-Command -Name Is-Dark-Mode -ErrorAction SilentlyContinue) {
            $IsDarkMode = Is-Dark-Mode
            if ($IsDarkMode) {
                $Color = "dark"
                Write-Host "[vimrc] Setting dark theme."
            }
            else {
                $Color = "light"
                Write-Host "[vimrc] Setting light theme."
            }
        }
        else {
            Write-Error "Is-Dark-Mode script does not exist. Please see "
                        "github/furkanzmc/dotfiles for the function."
        }
    }

    if ($ChangeAllInstances) {
        Write-Host "[vimrc] Changing color in all instances."
        Start-Process -NoNewWindow -Wait -FilePath python3 `
            -ArgumentList "$HOME/.dotfiles/nvim.py --command `"set background=$Color`""
    }

    if ($Color -ne "") {
        $env:VIMRC_BACKGROUND=$Color
    }

    if (Test-Path env:VIMRC_BACKGROUND) {
        Write-Host "[vimrc] Background color is set to ${env:VIMRC_BACKGROUND}."
    }
    else {
        Write-Host "[vimrc] VIMRC_BACKGROUND environment variable is not used."
    }
}

if (Test-Path env:PWSH_TIME -ErrorAction SilentlyContinue) {
    Write-Host "Loaded Pwsh-Vim in $($Stopwatch.Elapsed.TotalSeconds) seconds."
    $Stopwatch.Stop()
}
