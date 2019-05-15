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

# Settings for PSReadLine: https://github.com/lzybkr/PSReadLine
Import-Module PSReadLine
Set-PSReadLineOption -EditMode Vi
