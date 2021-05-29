if ($IsWindows) {
    Install-Module Pscx -Scope CurrentUser -AllowClobber
    Install-Module VSSetup -Scope CurrentUser
}

echo '. "~/.dotfiles/pwsh/profile.ps1"' >> $profile
if ($IsWindows) {
    echo '$env:PSModulePath += $([System.IO.Path]::PathSeparator) + ~/.dotfiles/pwsh/modules/'
    echo '. "~/.dotfiles/pwsh/pwsh_profile.ps1"' >> $profile
}
New-Item -Force -ItemType SymbolicLink -Path "~/.tmux.conf" -Target "~/.dotfiles/tmux.conf"

New-Item -ItemType Directory -Force -Path "~/.config/alacritty"
New-Item -Force -ItemType SymbolicLink -Path "~/.config/alacritty/alacritty.yml" -Target "~/.dotfiles/terminals/alacritty.yml"

New-Item -ItemType Directory -Force -Path "~/.config/karabiner/assets/complex_modifications/"
New-Item -Force -ItemType SymbolicLink -Path "~/.config/karabiner/assets/complex_modifications/karabiner_vi_style.json" -Target "~/.dotfiles/karabiner_vi_style.json"

New-Item -ItemType Directory -Force -Path "~/.hammerspoon"

foreach ($file in Get-ChildItem -Path "~/.dotfiles/hammerspoon/") {
    $fileName = Split-Path $file -Leaf
    New-Item -Force -ItemType SymbolicLink -Target $file -Path ~/.hammerspoon/$fileName
}
