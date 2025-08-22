#!/usr/bin/env zsh

############### Paths ###############

fpath=(
    ~/.local/zsh
    ~/.zsh
    $fpath
)

path+=~/.bin
path+=~/.local/bin

brew_prefix=$(brew --prefix)

############### Tab completions ###############

autoload -Uz compinit && compinit
autoload -Uz bashcompinit && bashcompinit

zstyle ':completion:*' menu select
zmodload zsh/complist

# SHIFT-TAB
bindkey -M menuselect '^[[Z' reverse-menu-complete

# git tab completions
zstyle ':completion:*:*:git:*' script ~/.local/bin/git-completion.bash

if type stack &> /dev/null; then
    eval "$(stack --bash-completion-script stack)"
fi

############### History ###############

SAVEHIST=10000
HISTSIZE=10000
setopt INC_APPEND_HISTORY_TIME
# add timestamp to history; use `history -i` to view
setopt EXTENDED_HISTORY

# UP/DOWN
bindkey '\e[A' history-search-backward
bindkey '\e[B' history-search-forward

# CTRL-R - search shell history
__fzf-ctrl-r-opts() {
    local opts=(
        --preview 'sed -E "s/[[:digit:]]+//;s/[[:space:]]+//;" <<< {}'
        --preview-window 'down,2,wrap'
        --height 70%
    )
    echo ${(q)opts[*]}
}
export FZF_CTRL_R_OPTS="$(__fzf-ctrl-r-opts)"

############### Key bindings ###############

bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^O' accept-line-and-down-history

autoload -U edit-command-line
zle -N edit-command-line
bindkey '^X' edit-command-line

export WORDCHARS="*?_-.[]~=/&;!#$%^(){}<>|@'\":"

# ALT-LEFT
function backward-word-segment {
    local WORDCHARS="$(tr -d '/-' <<< $WORDCHARS)"
    zle emacs-backward-word
}
zle -N backward-word-segment
bindkey '^[[1;3D' backward-word-segment

# CTRL-LEFT
function backward-word-alphanum {
    local WORDCHARS=
    zle emacs-backward-word
}
zle -N backward-word-alphanum
bindkey '^[[1;5D' backward-word-alphanum

# ALT-RIGHT
function forward-word-segment {
    local WORDCHARS="$(tr -d '/-' <<< $WORDCHARS)"
    zle emacs-forward-word
}
zle -N forward-word-segment
bindkey '^[[1;3C' forward-word-segment

# CTRL-RIGHT
function forward-word-alphanum {
    local WORDCHARS=
    zle emacs-forward-word
}
zle -N forward-word-alphanum
bindkey '^[[1;5C' forward-word-alphanum

# ALT-BACKSPACE
function backward-kill-word-segment {
    local WORDCHARS="$(tr -d '/-' <<< $WORDCHARS)"
    zle vi-backward-kill-word
}
zle -N backward-kill-word-segment
bindkey '^[^?' backward-kill-word-segment

bindkey '^W' backward-kill-word

############### Colors ###############

# Show colors in 'ls'
# https://unix.stackexchange.com/a/2904
export CLICOLOR=xterm-color

# Set 'ls' colors
# https://geoff.greer.fm/lscolors/
export LSCOLORS="ExGxGxDxCxEgEdxbxgxcxd"

# Set zsh tab completion colors
# https://geoff.greer.fm/lscolors/
zstyle ':completion:*' list-colors 'di=1;34:ln=1;36:so=1;36:pi=1;33:ex=1;32:bd=1;34;46:cd=1;34;43:su=0;41:sg=0;46:tw=0;42:ow=0;43'

# Set 'jq' colors
# https://stedolan.github.io/jq/manual/#Colors
function {
    local jq_color_parts=(
        '1;31' # null
        '1;35' # false
        '1;35' # true
        '1;33' # numbers
        '0;32' # strings
        '0;39' # arrays
        '0;39' # objects
    )
    export JQ_COLORS="${(j[:])jq_color_parts}"
}

############### File system helpers ###############

alias ll="ls -lhAt"
alias desk="cd ~/Desktop"

# touch a file, creating the directory if it doesn't already exist
function touch {
    local f
    for f in "$@"; do
        mkdir -p "$(dirname "$f")"
        command touch "$f"
    done
}

# rename the given file
function rn {
    local old=${1?}
    local new=${2?}
    mv $old "$(dirname $old)/${new}"
}

# change the extension of the given file
function chext {
    local old=${1?}
    local ext=${2?}
    if [[ $ext != .* ]]; then
        ext=".${ext}"
    fi

    mv $old "$(dirname $old)/$(basename $old | awk -F '.' '{ print $1 }')${ext}"
}

############### Haskell ###############

# GHCup
path+=~/.ghcup/bin
path+=~/.cabal/bin

if [[ $(uname -m) == 'arm64' ]]; then
    # llvm@12, for arm64 stack
    path+="${brew_prefix}/opt/llvm@12/bin"
    # export LDFLAGS="-L/opt/homebrew/opt/llvm@12/lib -Wl,-rpath,/opt/homebrew/opt/llvm@12/lib"
    # export CPPFLAGS="-I/opt/homebrew/opt/llvm@12/include"

    # https://gitlab.haskell.org/ghc/ghc/-/issues/20592
    export C_INCLUDE_PATH="$(xcrun --show-sdk-path)/usr/include/ffi"
fi

############### Git helpers ###############

function git {
    case "$1" in
        (root) cd "$(git rev-parse --show-cdup)" ;;
        (*) command git "$@" ;;
    esac
}

# CTRL-G - Paste the selected commit(s) into the command line
__git-log-fzf() {
    if ! git is-in-repo; then
        return
    fi

    __commits() {
        local log_max_num_logs=500
        local log_opts=(
            --oneline
            --color=always
        )
        # put commits on this branch first
        git l ${log_opts[@]}
        # then all commits
        git log ${log_opts[@]} --branches "-${log_max_num_logs}"
    }

    local fzf_opts=(
        --header=${LBUFFER}
        --ansi
        --nth=2..
        --no-sort
        --reverse
        --bind=ctrl-z:ignore
        --multi
        --preview 'awk "{ print \$1 }" <<< {} | xargs git show --color=always'
        --preview-window 'down,70%'
    )

    setopt localoptions pipefail no_aliases 2> /dev/null
    local item
    __commits | fzf ${fzf_opts[@]} | while read item; do
        awk '{ printf $1 " " }' <<< "${item}"
    done
    local ret=$?
    echo
    return $ret
}
fzf-git-commit-widget() {
    LBUFFER="${LBUFFER}$(__git-log-fzf)"
    local ret=$?
    zle reset-prompt
    return $ret
}
zle -N fzf-git-commit-widget
bindkey '^G' fzf-git-commit-widget

# CTRL-B - Print the given git branch to the command line, or check it out
__git-branch-fzf() {
    if ! git is-in-repo; then
        return
    fi

    setopt localoptions pipefail no_aliases 2> /dev/null
    git bm --fzf | fzf --ansi --accept-nth 1 "$@" | xargs
}
fzf-git-branch-widget() {
    if [[ -n "${LBUFFER}" ]]; then
        LBUFFER="${LBUFFER}$(__git-branch-fzf --multi)"
    else
        local branch="$(__git-branch-fzf)"
        if [[ -n "${branch}" ]]; then
            LBUFFER="git checkout ${branch}"
            zle accept-line
        fi
    fi
}
zle -N fzf-git-branch-widget
bindkey '^B' fzf-git-branch-widget

__checkout_branch() {
    local name=$1
    local branch="$(git branch --format '%(refname:short)' | grep "${name}" | head -n1)"
    if [[ -z "${branch}" ]]; then
        echo "No branch matching ${name}" >&2
        return 1
    fi

    echo ">>> git checkout ${branch}" >&2
    git checkout "${branch}"
}

alias gb=__checkout_branch

############### Docker helpers ###############

alias dc='docker compose'

function docker {
    if [[ $# == 1 && $1 == "images" ]]; then
        docker-images
    else
        command docker "$@"
    fi
}

############### Miscellaneous ###############

alias grep="grep --color"

export EDITOR=vim
eval "$(export_aws)"

############### Prompt ###############

eval "$(starship init zsh)"

############### Command border ###############

zmodload zsh/datetime

function __get_time {
    strftime '%s.%N'
}

__ZSH_TIMESTAMP_BEGIN_PREV_CMD=

function start_command_border {
    local input=$3
    if [[ -z $input ]]; then
        return
    fi

    # get starting time
    __ZSH_TIMESTAMP_BEGIN_PREV_CMD="$(__get_time)"

    # show starting time
    _print_time --fill '┈' --fill-color=237
}

function end_command_border {
    local retval=$?

    # if a previous command was run
    if [[ -n "${__ZSH_TIMESTAMP_BEGIN_PREV_CMD}" ]]; then
        # show ending time on the right
        _print_time --end $'\r'

        # get elapsed time
        local elapsed_time="$(print -f '%.4f' "$(( $(__get_time) - __ZSH_TIMESTAMP_BEGIN_PREV_CMD ))")"

        # show emoji based on exit code of last command
        local code_display
        case $retval in
            (0) code_display="👌" ;;
            (1) code_display="❗" ;;
            (*) code_display="❗%F{red}(code=${retval})%f " ;;
        esac
        print -P "${code_display}%F{250}(elapsed=${elapsed_time}s)%f "

        __ZSH_TIMESTAMP_BEGIN_PREV_CMD=
    fi
}

preexec_functions+=(start_command_border)
precmd_functions+=(end_command_border)

############### Window title ###############

function set_window_title {
    # set title to the name of the current directory, or
    # the name of the directory of the top-level git repo

    local canonical_dir="$(print -P '%1~')"
    if git is-in-repo; then
        canonical_dir="$(basename "$(git rev-parse --show-toplevel)")"
    fi

    local title="$(basename $canonical_dir)"
    if [[ $title = 'wezterm' ]]; then
        # https://github.com/wez/wezterm/issues/3021
        title='wezterm*'
    fi

    echo -ne "\033]0;$title\007"
}

# set title on initialization + whenever PWD changes
set_window_title
chpwd_functions+=(set_window_title)

############### wezterm ###############

WEZTERM_APP=$(find "${brew_prefix}/Caskroom" -name 'WezTerm.app')
source $WEZTERM_APP/Contents/Resources/wezterm.sh

############### zsh-syntax-highlighting ###############

source "${brew_prefix}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

typeset -A ZSH_HIGHLIGHT_STYLES

ZSH_HIGHLIGHT_STYLES[globbing]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=cyan'

############### zsh-autosuggestions ###############

source "${brew_prefix}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

############### fzf ###############

source "${brew_prefix}/opt/fzf/shell/completion.zsh"
source "${brew_prefix}/opt/fzf/shell/key-bindings.zsh"

export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
