#!/bin/bash

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    if [ $? -ne 0 ]; then
        echo "Failed to install Homebrew."
        exit 1
    fi
    echo "Homebrew has been installed."
else
    echo "Homebrew is already installed."
fi

# Check if the brew.packages file exists
packages_file="$HOME/.dotfiles/brew.packages"
if [ ! -f "$packages_file" ]; then
    echo "The brew.packages file does not exist."
else
    # Read the list of installed packages into an array
    installed_packages=($(brew list))

    # Install packages listed in brew.packages if not already installed
    while read -r package; do
        if [[ ! " ${installed_packages[@]} " =~ " ${package} " ]]; then
            echo "Installing package: $package"
            brew install "$package"
        else
            echo "Package $package is already installed."
        fi
    done < "$packages_file"
fi

# Create the "Development" folder
dev_folder="$HOME/Development"
if [ ! -d "$dev_folder" ]; then
    echo "Creating the 'Development' folder..."
    mkdir -p "$dev_folder"
else
    echo "'Development' folder already exists at $dev_folder."
fi

if [ ! -d "~/.nvim.lua" ]; then
    echo "Creating .nvim.lua"

    touch ~/.nvim.lua
else
    echo ".nvim.lua already exists!"
fi

# Check if the current login shell is PowerShell (pwsh)
current_shell=$(dscl . -read ~/ UserShell | awk '{print $2}')
if [ "$current_shell" != "/usr/local/bin/pwsh" ]; then
    echo "Changing the login shell to PowerShell (pwsh)..."
    chsh -s /usr/local/bin/pwsh
    if [ $? -ne 0 ]; then
        echo "Failed to change the login shell to PowerShell (pwsh)."
    else
        echo "Login shell changed to PowerShell (pwsh)."
    fi
else
    echo "Login shell is already set to PowerShell (pwsh)."
fi

if ! command -v nvim &> /dev/null; then
    echo "Neovim is not installed. Building from source..."
    if [ ! -d "$dev_folder/random" ]; then
        echo "Creating random folder."
        mkdir -p $dev_folder/Development/random
    fi

    if [ ! -d "$dev_folder/tools" ]; then
        echo "Creating tools folder."

        mkdir -p $dev_folder/Development/tools/bin
    fi

    if [ ! -d "$dev_folder/random/neovim" ]; then
        git clone --depth 1 https://github.com/neovim/neovim.git $dev_folder/random/neovim
    fi

    pwsh -Command Build-Neovim -SourcePath $dev_folder/random/neovim -InstallPath $HOME/Development/tools/nvim -Install
    ln -s $HOME/Development/tools/nvim/bin/nvim $HOME/Development/tools/bin
else
    echo "Homebrew is already installed."
fi

echo "Script completed."
