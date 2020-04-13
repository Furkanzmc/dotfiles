Push-Location ~/.dotfiles/vim

if (Test-Path ~/.vimrc) {
    Copy-Item -Path ~/.vimrc -Destination ~/.vimrc.orig
}

echo 'set runtimepath+=~/.dotfiles/vim

source ~/.dotfiles/vim/init.vim
' > ~/.vimrc

New-Item -Force -ItemType Directory -Path ~/.vim/pack/minpac/opt/
New-Item -Force -ItemType Directory -Path ~/.vim/pack/minpac/start/

if ($IsWindows) {
    git clone https://github.com/k-takata/minpac.git $env:USERPROFILE/.vim/pack/minpac/opt/minpac
}
else {
    git clone https://github.com/k-takata/minpac.git ~/.vim/pack/minpac/opt/minpac
}

if ($IsWindows) {
    New-Item -Force -ItemType SymbolicLink `
        -Target $env:USERPROFILE/.dotfiles/vim/vimrcs/ginit.vim `
        -Path $env:LOCALAPPDATA/nvim/ginit.vim
}

Pop-Location

echo "Installed the Ultimate Vim configuration successfully! Enjoy :-)"
