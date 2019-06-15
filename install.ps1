Install-Module posh-git -Scope CurrentUser -AllowPrerelease -Force

if ($IsWindows) {
    Install-Module Pscx -Scope CurrentUser
}

echo '. "~/.dotfiles/pwsh_profile.ps1"' >> $profile
