# General

bind "set completion-ignore-case on"
set editing-mode vi
set show-mode-in-prompt on
set vi-ins-mode-string "+"
set vi-cmd-mode-string ":"

alias vim=nvim
export EDITOR='nvim'

command -v exa >/dev/null 2>&1 && {
    alias ls=exa
}
command -v fd >/dev/null 2>&1 && {
    alias find=fd
}
command -v bat >/dev/null 2>&1 && {
    alias cat=bat
}

copy_pwd() {
    pwd | pbcopy
}

# -----

# Functions

enable-dylib-verbose() {
    export DYLD_PRINT_LIBRARIES=1
    export DYLD_PRINT_LIBRARIES_POST_LAUNCH=1
    export DYLD_PRINT_RPATHS=1
}

disable-dylib-verbose() {
    export DYLD_PRINT_LIBRARIES=0
    export DYLD_PRINT_LIBRARIES_POST_LAUNCH=0
    export DYLD_PRINT_RPATHS=0
}

pub_ip() {
    curl http://ipconfig.io/ip
}

search_history() {
    history | rg '$1'
}

bashrc() {
    nvim ~/.bash_profile
}

is_older() {
    if [ $1 -ot $2 ]; then
        return 0
    else
        return -1
    fi
}

is_newer() {
    if [ $1 -nt $2 ]; then
        return 0
    else
        return -1
    fi
}

install-git-completion() {
    curl https://raw.githubusercontent.com/git/git/53f9a3e157dbbc901a02ac2c73346d375e24978c/contrib/completion/git-completion.bash -o ~/.git-completion.bash
}

function replace_in_dir() {
    rg -l -F "${1}" | xargs sed -i -e "s/${1}/${2}/g"
}

# Script taken from: https://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/x329.html
print-available-colors() {
    T='gYw'   # The test text

    echo -e "\n                 40m     41m     42m     43m\
         44m     45m     46m     47m";

    for FGs in '    m' '   1m' '  30m' '1;30m' '  31m' '1;31m' '  32m' \
               '1;32m' '  33m' '1;33m' '  34m' '1;34m' '  35m' '1;35m' \
               '  36m' '1;36m' '  37m' '1;37m';
      do FG=${FGs// /}
      echo -en " $FGs \033[$FG  $T  "
      for BG in 40m 41m 42m 43m 44m 45m 46m 47m;
        do echo -en "$EINS \033[$FG\033[$BG  $T  \033[0m";
      done
      echo;
    done
}


# -----

# macOS Commands

## Lock screen
OS=`uname`

if [ "${OS}" == "Darwin" ]; then

    post_notification() {
        if [ $2 -e ""]; then
            title="Notification"
        else
            title=$2
        fi

        osascript -e "display notification \"$1\" with title \"$title\""
    }

    cd-desktop() {
        cd ~/Desktop
    }

    cd-downloads() {
        cd ~/Downloads
    }

    cd-icloud() {
        cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/
    }

    alias lock_screen="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
fi


# -----

# Git

branch_recency() {
    for k in `git branch | sed s/^..//`; do echo -e `git log -1 --pretty=format:"%Cgreen%ci %Cblue%cr%Creset" $k --`\\t"$k";done | sort
}

# Enable Git completion
if [ -f /Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash ]; then
    source "/Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash"
elif [ -f ~/.git-completion.bash ]; then
    source ~/.git-completion.bash
fi

git config --global alias.st 'status'
git config --global alias.stage 'add'
git config --global alias.unstage 'reset HEAD --'

git config --global alias.last 'log -1 HEAD'
git config --global alias.logall "log --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
git config --global alias.logcurrent "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

git config --global alias.logpretty "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
git config --global alias.tasks "!rg 'TODO|FIXME' ./"
git config --global alias.discard 'checkout --'

git-difflog() {
    git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --name-status $1..$2
}

git config --global color.status.changed "magenta normal bold"
git config --global color.status.added "blue normal bold"
git config --global color.status.unmerged "yellow normal bold"

git-set-author() {
    git config user.name "$1"
    git config user.email "$2"
}

# -----

# TMUX
# tmux session code is taken from mislav:
# https://github.com/mislav/dotfiles/blob/master/bin/tmux-session

tmux-dump() {
  local d=$'\t'
  tmux list-windows -a -F "#S${d}#W${d}#{pane_current_path}" -t $1
}

tmux-save() {
    tmux-dump $1 > $2
}

tmux_terminal_size() {
  stty size 2>/dev/null | awk '{ printf "-x%d -y%d", $2, $1 }'
}

tmux_session_exists() {
  tmux has-session -t "$1" 2>/dev/null
}

tmux_add_window() {
  tmux new-window -d -t "$1:" -n "$2" -c "$3"
}

tmux_new_session() {
  cd "$3" &&
  tmux new-session -d -s "$1" -n "$2" $4
}

tmux-restore() {
  tmux start-server
  local count=0
  local dimensions="$(tmux_terminal_size)"

  while IFS=$'\t' read session_name window_name dir; do
    if [[ -d "$dir" && $window_name != "log" && $window_name != "man" ]]; then
      if tmux_session_exists "$session_name"; then
        tmux_add_window "$session_name" "$window_name" "$dir"
      else
        tmux_new_session "$session_name" "$window_name" "$dir" "$dimensions"
        count=$(( count + 1 ))
      fi
    fi

  done < $1
  echo "restored $count sessions"
}

#
# Tmux launcher
#
# See:
#     http://github.com/brandur/tmux-extra
#
# Modified version of a script orginally found at:
#     http://forums.gentoo.org/viewtopic-t-836006-start-0.html
# Taken from: https://github.com/brandur/tmux-extra/blob/master/tmx
# and slightly modified.

# Works because bash automatically trims by assigning to variables and by
# passing arguments
trim() { echo $1; }

run-tmux() {
    base_session="main"
# This actually works without the trim() on all systems except OSX
    tmux_nb=$(trim `tmux ls | grep "^$base_session" | wc -l`)
    if [[ "$tmux_nb" == "0" ]]; then
        echo "Launching tmux base session $base_session ..."
        tmux new-session -s $base_session
    else
        # Make sure we are not already in a tmux session
        if [[ -z "$TMUX" ]]; then
            # Kill defunct sessions first
            old_sessions=$(tmux ls 2>/dev/null | egrep "^[0-9]{14}.*[0-9]+\)$" | cut -f 1 -d:)
            for old_session_id in $old_sessions; do
                tmux kill-session -t $old_session_id
            done

            echo "Launching copy of base session $base_session ..."
            # Use the number of windows in the group to name the new session.
            # Explude the first main session from the count.
            group_count=`tmux ls | rg -F -v 'main:' | rg -F '(group main) (attached)' | wc -l | xargs`
            group_count=$((group_count + 1))
            session_id="main-$group_count"
            # Create a new session (without attaching it) and link to base session
            # to share windows
            tmux new-session -d -t $base_session -s $session_id
            # Attach to the new session
            tmux attach-session -t $session_id
            # When we detach from it, kill the session
            tmux kill-session -t $session_id
        fi
    fi
}


if [ -n "$NVIM_LISTEN_ADDRESS" ]; then
    echo "NeoVim Terminal settings go here."
    # NeoVim related settings;
    # TODO: Change the editor so files open in the current NeoVim process.
elif [ -n "$DOTFILES_ENABLE_TMUX" ]; then
    run-tmux
fi
