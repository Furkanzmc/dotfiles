Install-Module posh-git -Scope CurrentUser -AllowPrerelease -Force

if ($IsWindows) {
    Install-Module Pscx -Scope CurrentUser -AllowClobber
    Install-Module VSSetup -Scope CurrentUser
}

echo '. "~/.dotfiles/pwsh_profile.ps1"' >> $profile
