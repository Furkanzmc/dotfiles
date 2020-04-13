#!/bin/sh
set -e

cd ~/.dotfiles/vim

echo 'set runtimepath+=~/.dotfiles/vim

source ~/.dotfiles/vim/vimrcs/init.vim
' > ~/.vimrc

mkdir -p ~/.vim/pack/minpac/start/

git clone https://github.com/k-takata/minpac.git ~/.vim/pack/minpac/opt/minpac

echo "Installed the Ultimate Vim configuration successfully! Enjoy :-)"
