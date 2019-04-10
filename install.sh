# !/bin/sh

ln -sf ~/.dotfiles/tmux.conf ~/.tmux.conf
ln -sf ~/.dotfiles/karabiner_vi_style.json ~/.config/karabiner/assets/complex_modifications/

mkdir -p ~/.hammerspoon
ln -sf ~/.dotfiles/hammerspoon/* ~/.hammerspoon/
ln -sf ~/.dotfiles/alacritty.yaml ~/.alacritty.yaml

echo "Installed configurations."
