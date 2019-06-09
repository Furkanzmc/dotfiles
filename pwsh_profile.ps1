# Settings for PSReadLine: https://github.com/lzybkr/PSReadLine
Import-Module PSReadLine
Set-PSReadLineOption -EditMode Vi

# Functions
function export($name, $value) {
    [System.Environment]::SetEnvironmentVariable($name, $value)
}

function replace_in_dir($from, $to) {
    if ($IsMacOS) {
        rg -l -F "$from" | xargs sed -i -e "s/$from/$to/g"
    }
    else {
        Write-Host 'replace_in_dir is not supported on this platform.'
    }
}

if ($IsMacOS) {
    $env:PATH += ":/usr/local/bin"

    export EDITOR 'nvim'

    if (Test-Path '/usr/local/bin/exa') {
        Set-Alias ls /usr/local/bin/exa
    }

    if (Test-Path '/usr/local/bin/fd') {
        Set-Alias find /usr/local/bin/fd
    }

    if (Test-Path '/usr/local/bin/bat') {
        Set-Alias cat /usr/local/bin/bat
    }

    if (Test-Path '/usr/local/bin/nvim') {
        Set-Alias vim /usr/local/bin/nvim
    }

    function post-notification($message, $title) {
        osascript -e "display notification \`"$message\`" with title \`"$title\`""
    }

    function cd-desktop() {
        cd ~/Desktop
    }

    function cd-downloads() {
        cd ~/Downloads
    }

    function cd-icloud() {
        cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/
    }

    alias lock_screen="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
} # End MacOS


# Git
git config --global alias.st 'status'
git config --global alias.stage 'add'
git config --global alias.unstage 'reset HEAD --'

git config --global alias.last 'log -1 HEAD'
git config --global alias.logall "log --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
git config --global alias.logcurrent "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

git config --global alias.logpretty "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
git config --global alias.tasks "!rg 'TODO|FIXME' ./"
git config --global alias.discard 'checkout --'

function git-difflog($from, $to) {
    git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --name-status $from..$to
}

git config --global color.status.changed "magenta normal bold"
git config --global color.status.added "blue normal bold"
git config --global color.status.unmerged "yellow normal bold"

function git-set-author($name, $email) {
    git config user.name "$name"
    git config user.email "$email"
}
# -----

