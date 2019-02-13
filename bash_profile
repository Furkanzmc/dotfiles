# General
# -----

bind "set completion-ignore-case on"
alias vim=nvim
export EDITOR='nvim'

alias ls=exa
alias find=fd
alias cat=bat

# -----

# Functions
# -----

pub_ip() {
    curl http://ipconfig.io/ip
}

search_history() {
    history | rg '$1'
}

bashrc() {
    nvim ~/.bash_profile
}

typora() {
    open $1 -a "Typora"
}

desktop() {
    open ~/Desktop -a "Finder"
}

downloads() {
    open ~/Downloads -a "Finder"
}

icloud() {
    open ~/Library/Mobile\ Documents/com~apple~CloudDocs/
}

cd_icloud() {
    cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/
}

install-git-completion() {
    curl https://raw.githubusercontent.com/git/git/53f9a3e157dbbc901a02ac2c73346d375e24978c/contrib/completion/git-completion.bash -o ~/.git-completion.bash
}

function replace_in_dir() {
    rg -l -F "${1}" | xargs sed -i -e "s/${1}/${2}/g"
}


# -----

# macOS Commands
# -----

## Lock screen
alias lock_screen="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"

# -----

# Git
# -----

branch_recency() {
    for k in `git branch | sed s/^..//`; do echo -e `git log -1 --pretty=format:"%Cgreen%ci %Cblue%cr%Creset" $k --`\\t"$k";done | sort
}

# Enable Git completion
if [ -f /Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash ]; then
    source "/Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash"
elif [ -f ~/.git-completion.bash ]; then
    source ~/.git-completion.bash
fi

# Create an alias for `git stage`
git config --global alias.unstage 'add'
# Create an alias for `git unstage`
git config --global alias.unstage 'reset HEAD --'
# Create an alias to see the last commit `git last`
git config --global alias.last 'log -1 HEAD'
# Open GitX with `git visual`
git config --global alias.visual '!open ./ -a "GitX"'
# Use `git logall` to log all the changes
git config --global alias.logall "log --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
# Use `git logcurrent` to log the current branch
git config --global alias.logcurrent "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
git config --global alias.logpretty "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
# Use `git tasks` to list the TODO and FIXME entries in the code
git config --global alias.tasks "ag 'TODO|FIXME' ./"

git-difflog() {
    git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --name-status $1..$2
}

git config --global color.status.changed "magenta normal bold"
git config --global color.status.added "blue normal bold"
git config --global color.status.unmerged "yellow normal bold"
# -----
