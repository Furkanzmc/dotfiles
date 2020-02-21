Install-Module posh-git -Scope CurrentUser -AllowPrerelease -Force

if ($IsWindows) {
    Install-Module Pscx -Scope CurrentUser -AllowClobber
    Install-Module VSSetup -Scope CurrentUser
}

echo '. "~/.dotfiles/pwsh_profile.ps1"' >> $profile
New-Item -Force -ItemType SymbolicLink -Path "~/.dotfiles/tmux.conf" -Target "~/.tmux.conf"
New-Item -Force -ItemType SymbolicLink -Path "~/.dotfiles/alacritty.yml" -Target "~/.alacritty.yml"

New-Item -Force -ItemType SymbolicLink -Path "~/.dotfiles/karabiner_vi_style.json" -Target "~/.config/karabiner/assets/complex_modifications/"

New-Item -ItemType Directory -Force -Path "~/.hammerspoon"
New-Item -Force -ItemType SymbolicLink -Path "~/.dotfiles/karabiner_vi_style.json" -Target "~/.config/karabiner/assets/complex_modifications/"

foreach ($file in Get-ChildItem -Path "~/.dotfiles/hammerspoon/") {
    $fileName = Split-Path $file -Leaf
    New-Item -Force -ItemType SymbolicLink -Target $file -Path ~/.hammerspoon/$fileName
}

New-Item -Force -ItemType SymbolicLink -Path "~/.dotfiles/iterm2.json" -Target "~/Library/Application\ Support/iTerm2/DynamicProfiles"