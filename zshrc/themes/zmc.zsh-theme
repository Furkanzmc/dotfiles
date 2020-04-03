#
# Changed version of Sobole ZSH Theme
#
# Author: Nikita Sobolev, github.com/sobolevn
# License: WTFPL
# https://github.com/sobolevn/sobole-zsh-theme

PROMPT='
$(current_venv)$(current_dir)$(vcs_prompt_info)
$(current_caret) '
PROMPT2='. '

_return_status="%(?..%{$fg[red]%}%? !!%{$reset_color%})"

RPROMPT='%{$(echotc UP 1)%} $(vcs_status) ${_return_status}%{$(echotc DO 1)%}'

function current_caret() {
    # This function sets caret color and sign
    # based on theme and privileges.
    if [[ "$USER" == "root" ]]; then
        CARET_COLOR="red"
        CARET_SIGN="$"
    else
        CARET_SIGN="=>"
        CARET_COLOR="green"
    fi

    echo "%{$fg[$CARET_COLOR]%}$CARET_SIGN%{$reset_color%}"
}

function vcs_prompt_info() {
    git_prompt_info
}

function vcs_status() {
    git_prompt_status
}

function current_dir() {
    # Settings up current directory and settings max width for it:
    local _max_pwd_length="65"
    local color="blue"

    if [[ $(echo -n $PWD | wc -c) -gt ${_max_pwd_length} ]]; then
        echo "%{$fg_bold[$color]%}%-2~ ... %3~%{$reset_color%} "
    else
        echo "%{$fg_bold[$color]%}%~%{$reset_color%} "
    fi
}

# ----------------------------------------------------------------------------
# virtualenv settings
# These settings changes how virtualenv is displayed.
# ----------------------------------------------------------------------------

# Disable the standard prompt:
export VIRTUAL_ENV_DISABLE_PROMPT=1

function current_venv() {
    if [[ ! -z "$VIRTUAL_ENV" ]]; then
        # Show this info only if virtualenv is activated:
        local dir=$(basename "$VIRTUAL_ENV")
        echo "($dir) "
    fi
}

# ----------------------------------------------------------------------------
# VCS specific colors and icons
# These settings defines how icons and text is displayed for
# vcs-related stuff. We support only `git`.
# ----------------------------------------------------------------------------

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[green]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}]"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN=" %{$fg[green]%}✔%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[cyan]%}§%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%}✚%{$reset_color%}"
