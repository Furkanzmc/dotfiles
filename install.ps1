if ($IsWindows) {
    Install-Module Pscx -Scope CurrentUser -AllowClobber
    Install-Module VSSetup -Scope CurrentUser
}

# Create the necessary folders if they don't exist
$profileFolder = [System.IO.Path]::GetDirectoryName($PROFILE)
    if (-Not (Test-Path -Path $profileFolder)) {
        Write-Output "Creating profile folder: $profileFolder"
        New-Item -Path $profileFolder -ItemType Directory -Force
    }

Write-Output '. "~/.dotfiles/pwsh/profile.ps1"' >> $PROFILE
if ($IsWindows) {
    Write-Output '$env:PSModulePath += $([System.IO.Path]::PathSeparator) + $HOME/.dotfiles/pwsh/modules/'
}

Write-Output '[include]' >> ~/.gitconfig
Write-Output '    path = ~/.dotfiles/gitconfig' >> ~/.gitconfig

New-Item -ItemType Directory -Force -Path "~/.config/alacritty"

if ($IsMacOS) {
    New-Item -Force -ItemType SymbolicLink -Path "$HOME/.config/alacritty/alacritty.yml" -Target "$HOME/.dotfiles/terminals/alacritty_macos.yml"
}
else {
    New-Item -Force -ItemType SymbolicLink -Path "$HOME/.config/alacritty/alacritty.yml" -Target "$HOME/.dotfiles/terminals/alacritty_windows.yml"
}

if (Test-Path -Path env:FIREFOX_PROFILE_PATH) {
    $profileFolder = Join-Path -Path $env:FIREFOX_PROFILE_PATH -ChildPath chrome
    $chromePath = Join-Path -Path $profileFolder -ChildPath userChrome.css
    if (-Not (Test-Path -Path $profileFolder)) {
        git clone https://github.com/MrOtherGuy/firefox-csshacks.git $profileFolder
    }

    $autoHidePath = Join-Path -Path $profileFolder -ChildPath autoHide.css
    New-Item -Force -ItemType SymbolicLink -Path $autoHidePath -Target "$HOME/.dotfiles/firefox/autoHide.css"
    if ($IsMacOS) {
        New-Item -Force -ItemType SymbolicLink -Path $chromePath -Target "$HOME/.dotfiles/firefox/userChrome_macOS.css"
    }
    else {
        New-Item -Force -ItemType SymbolicLink -Path $chromePath -Target "$HOME/.dotfiles/firefox/userChrome_windows.css"
    }
}

$nvimConfigPath = ""
if ($IsMacOS) {
    $nvimConfigPath = "$HOME/.config/nvim"
}
else {
    $nvimConfigPath = "$HOME/AppData/Local/nvim"
}

if (-Not (Test-Path -Path $nvimConfigPath)) {
    New-Item -Path $nvimConfigPath -ItemType Directory -Force
}

New-Item -Force -ItemType SymbolicLink -Path "$nvimConfigPath/init.lua" -Target "$HOME/.dotfiles/vim/init.lua"

if ($IsMacOS) {
    New-Item -ItemType Directory -Force -Path "$HOME/.config/karabiner/assets/complex_modifications/"
    New-Item -Force -ItemType SymbolicLink -Path "$HOME/.config/karabiner/assets/complex_modifications/karabiner_vi_style.json" -Target "$HOME/.dotfiles/karabiner_vi_style.json"
    New-Item -ItemType Directory -Force -Path "~/.hammerspoon/Spoons"

    foreach ($file in Get-ChildItem -Path "~/.dotfiles/hammerspoon/") {
        $fileName = Split-Path $file -Leaf
        New-Item -Force -ItemType SymbolicLink -Target $file -Path $HOME/.hammerspoon/Spoons/$fileName
    }

    Write-Output 'hs.loadSpoon("zmc")' >> ~/.hammerspoon/init.lua
}
