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
    Write-Output '. "~/.dotfiles/pwsh/pwsh_profile.ps1"' >> $profile
}

Write-Output '[include]' >> ~/.gitconfig
Write-Output '    path = ~/.dotfiles/gitconfig' >> ~/.gitconfig

New-Item -ItemType Directory -Force -Path "~/.config/alacritty"
New-Item -Force -ItemType SymbolicLink -Path "$HOME/.config/alacritty/alacritty.yml" -Target "$HOME/.dotfiles/terminals/alacritty.yml"

if ($IsMacOS) {
    if (-Not (Test-Path -Path ~/.config/nvim)) {
        New-Item -Path ~/.config/nvim -ItemType Directory -Force
        New-Item -Force -ItemType SymbolicLink -Path "$HOME/.config/nvim/init.lua" -Target "$HOME/.dotfiles/vim/init.lua"
    }

    New-Item -ItemType Directory -Force -Path "$HOME/.config/karabiner/assets/complex_modifications/"
    New-Item -Force -ItemType SymbolicLink -Path "$HOME/.config/karabiner/assets/complex_modifications/karabiner_vi_style.json" -Target "$HOME/.dotfiles/karabiner_vi_style.json"
    New-Item -ItemType Directory -Force -Path "~/.hammerspoon/Spoons"

    foreach ($file in Get-ChildItem -Path "~/.dotfiles/hammerspoon/") {
        $fileName = Split-Path $file -Leaf
        New-Item -Force -ItemType SymbolicLink -Target $file -Path $HOME/.hammerspoon/Spoons/$fileName
    }

    Write-Output 'hs.loadSpoon("zmc")' >> ~/.hammerspoon/init.lua
}
