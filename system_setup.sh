if ! [ -x "$(command -v "brew")" ]
then
    echo "Brew does not exist. Installing..."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

if ! [ -x "$(command -v "pwsh")" ]
then
    echo "Powershell does not exist. Installing..."
    brew cask install powershell
fi

pwsh -C ". ~/.dotfiles/system_setup.ps1; Setup-System"
