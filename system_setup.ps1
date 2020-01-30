# This script sets up a new machine with the default configurations I'm used to.
# Once run, it will do the following:
#     - Clone vimrc
#     - Set up a projects folder
#     - Clone the repositories to that folder.
#     - Install the tools I use.

if ($IsWindows) {
    Write-Error "Window is not yet supported."
}

function Clone-Vimrc() {
    Push-Location ~/

    if (Test-Path ~/.vim_runtime -ErrorAction SilentlyContinue) {
        Push-Location ~/.vim_runtime
        git pull
        Pop-Location
    }
    else {
        git clone https://github.com/Furkanzmc/vimrc.git ~/.vim_runtime
    }

    Pop-Location
}

function Setup-Projects() {
    New-Item -ItemType Directory -Force -Path "~/Projects"
}

function Install-Tools() {
    if (-not (Get-Command -Name brew -ErrorAction SilentlyContinue)) {
        Start-Process -NoNewWindow -Wait -Path /usr/bin/ruby -ArgumentList '-e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
    }

    Start-Process -NoNewWindow -Wait -Path brew -ArgumentList "install fzf bat exa fd nnn tmux neovim"

    # Cask
    Start-Process -NoNewWindow -Wait -Path brew -ArgumentList "cask install powershell alacritty iterm2 hammerspoon"

    Start-Process -NoNewWindow -Wait -Path open -ArgumentList "https://pqrs.org/osx/karabiner/"
    Start-Process -NoNewWindow -Wait -Path open -ArgumentList "https://www.sequelpro.com"
    Start-Process -NoNewWindow -Wait -Path open -ArgumentList "https://freemacsoft.net/appcleaner/"
    Start-Process -NoNewWindow -Wait -Path open -ArgumentList "https://apps.apple.com/us/app/microsoft-onenote/id784801555"
}

function Setup-System() {
    Clone-Vimrc
    Install-Tools
    Setup-Projects
}
