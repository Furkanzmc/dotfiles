if ($IsWindows) {
    Install-Module Pscx -Scope CurrentUser -AllowClobber
    Install-Module VSSetup -Scope CurrentUser
}

Write-Output '. "~/.dotfiles/pwsh/profile.ps1"' >> $profile
if ($IsWindows) {
    Write-Output '$env:PSModulePath += $([System.IO.Path]::PathSeparator) + ~/.dotfiles/pwsh/modules/'
    Write-Output '. "~/.dotfiles/pwsh/pwsh_profile.ps1"' >> $profile
}

Write-Output '[include]' >> ~/.gitconfig
Write-Output '    path = ~/.dotfiles/gitconfig' >> ~/.gitconfig

New-Item -ItemType Directory -Force -Path "~/.config/alacritty"
New-Item -Force -ItemType SymbolicLink -Path "~/.config/alacritty/alacritty.yml" -Target "~/.dotfiles/terminals/alacritty.yml"

if ($IsMacOS) {
    New-Item -ItemType Directory -Force -Path "~/.config/karabiner/assets/complex_modifications/"
    New-Item -Force -ItemType SymbolicLink -Path "~/.config/karabiner/assets/complex_modifications/karabiner_vi_style.json" -Target "~/.dotfiles/karabiner_vi_style.json"
    New-Item -ItemType Directory -Force -Path "~/.hammerspoon/Spoons"

    foreach ($file in Get-ChildItem -Path "~/.dotfiles/hammerspoon/") {
	$fileName = Split-Path $file -Leaf
	New-Item -Force -ItemType SymbolicLink -Target $file -Path ~/.hammerspoon/Spoons/$fileName
    }

    Write-Output 'hs.loadSpoon("zmc")' >> ~/.hammerspoon/init.lua
}
