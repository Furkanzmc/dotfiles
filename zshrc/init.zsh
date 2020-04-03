# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="zmc"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    dotenv
    django
    colored-man-pages
    vi-mode
)

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# {{
alias vim=nvim
alias nv=nvim

command -v exa >/dev/null 2>&1 && {
    alias ls=exa
}
command -v fd >/dev/null 2>&1 && {
    alias find=fd
}
command -v bat >/dev/null 2>&1 && {
    alias cat=bat
}

function copy-pwd() {
    pwd | pbcopy
}

# }}

export EDITOR='nvim'

# {{ Functions

command -v ctags >/dev/null 2>&1 && {
    function generate-cpp-tags() {
        ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .
    }
}

function enable-dylib-verbose() {
    export DYLD_PRINT_LIBRARIES=1
    export DYLD_PRINT_LIBRARIES_POST_LAUNCH=1
    export DYLD_PRINT_RPATHS=1
}

function disable-dylib-verbose() {
    export DYLD_PRINT_LIBRARIES=0
    export DYLD_PRINT_LIBRARIES_POST_LAUNCH=0
    export DYLD_PRINT_RPATHS=0
}

function public-ip() {
    curl http://ipconfig.io/ip
}

function is-older() {
    if [ $1 -ot $2 ]; then
        return 0
    else
        return -1
    fi
}

function is-newer() {
    if [ $1 -nt $2 ]; then
        return 0
    else
        return -1
    fi
}

function replace-in-dir() {
    rg -l -F "${1}" | xargs sed -i -e "s/${1}/${2}/g"
}

if [ -n "$NVIM_LISTEN_ADDRESS" ]; then
    command -v nvr >/dev/null 2>&1 && {
        alias nvmh="nvr -o"
            alias nvmv="nvr -O"
            alias nvmt="nvr --remote-tab"
            alias nvim="nvr"
        }
fi

# }}

# {{ macOS Commands

# OS=`uname`

# if [ $OS == "Darwin" ]; then
#     function post_notification() {
#         if [ $2 -e ""]; then
#             title="Notification"
#         else
#             title=$2
#         fi

#         osascript -e "display notification \"$1\" with title \"$title\""
#     }

#     function cd-desktop() {
#         cd ~/Desktop
#     }

#     function cd-downloads() {
#         cd ~/Downloads
#     }

#     function cd-icloud() {
#         cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/
#     }

#     alias lock_screen="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"

# fi


# }}

# {{ Git

function branch-recency() {
    for k in `git branch | sed s/^..//`; do echo -e `git log -1 --pretty=format:"%Cgreen%ci %Cblue%cr%Creset" $k --`\\t"$k";done | sort --reverse
    }

## -----

## TMUX
## tmux session code is taken from mislav:
## https://github.com/mislav/dotfiles/blob/master/bin/tmux-session

function tmux-dump() {
    local d=$'\t'
    tmux list-windows -a -F "#S${d}#W${d}#{pane_current_path}" -t $1
}

function tmux-save() {
    tmux-dump $1 > $2
}

function tmux_terminal_size() {
    stty size 2>/dev/null | awk '{ printf "-x%d -y%d", $2, $1 }'
}

function tmux_session_exists() {
    tmux has-session -t "$1" 2>/dev/null
}

function tmux_add_window() {
    tmux new-window -d -t "$1:" -n "$2" -c "$3"
}

function tmux_new_session() {
    cd "$3" &&
        tmux new-session -d -s "$1" -n "$2" $4
    }

function tmux-restore() {
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
function trim() { echo $1; }

function run-tmux() {
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
