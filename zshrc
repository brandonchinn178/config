#!/usr/bin/env zsh

############### Paths ###############

fpath=(
    ~/.local/zsh
    ~/.zsh
    $fpath
)

path+=~/.bin
path+=~/.local/bin

############### Tab completions ###############

autoload -Uz compinit && compinit
autoload -Uz bashcompinit && bashcompinit

zstyle ':completion:*' menu select
zmodload zsh/complist
bindkey -M menuselect '^[[Z' reverse-menu-complete

# git tab completions
zstyle ':completion:*:*:git:*' script ~/.local/bin/git-completion.bash

if type stack &> /dev/null; then
    eval "$(stack --bash-completion-script stack)"
fi

############### Key bindings ###############

bindkey '^R' history-incremental-search-backward

bindkey '^A' beginning-of-line
bindkey '^E' end-of-line

autoload -U edit-command-line
zle -N edit-command-line
bindkey '^X' edit-command-line

export WORDCHARS="*?_-.[]~=/&;!#$%^(){}<>|@'\":"

function backward-word-segment {
    local WORDCHARS="$(tr -d '/-' <<< $WORDCHARS)"
    zle emacs-backward-word
}
zle -N backward-word-segment
bindkey '^[b' backward-word-segment

function forward-word-segment {
    local WORDCHARS="$(tr -d '/-' <<< $WORDCHARS)"
    zle emacs-forward-word
}
zle -N forward-word-segment
bindkey '^[f' forward-word-segment

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

    mv $old "${old%\.*}${ext}"
}

############### AWS helpers ###############

function ecr() {
    aws ecr get-login-password --region us-west-2 \
        | docker login --username AWS --password-stdin 766357520640.dkr.ecr.us-west-2.amazonaws.com
}

############### Git helpers ###############

# Exit code 0 if currently in a git repo.
function in_git_repo {
    git rev-parse --is-inside-work-tree &> /dev/null
}

# Change directory to root of the git repo
function root {
    cd "$(git rev-parse --show-cdup)"
}

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

zmodload zsh/datetime

function __get_time {
    strftime '%s.%N'
}

__ZSH_TIMESTAMP_BEGIN_PREV_CMD=

function precmd {
    local retval=$?

    # if a previous command was run
    if [[ -n "${__ZSH_TIMESTAMP_BEGIN_PREV_CMD}" ]]; then
        # show ending time
        _print_time --end $'\r'

        # get elapsed time
        local elapsed_time="$(print -f '%.4f' "$(( $(__get_time) - __ZSH_TIMESTAMP_BEGIN_PREV_CMD ))")"

        # show emoji based on exit code of last command
        local code_display
        case $retval in
            (0) code_display="👌" ;;
            (1) code_display="❗" ;;
            (*) code_display="❗%F{red}(code=${retval})%f" ;;
        esac
        print -P "${code_display} %F{250}(elapsed=${elapsed_time}s)%f "

        __ZSH_TIMESTAMP_BEGIN_PREV_CMD=
    fi

    # set title to the name of the current directory, or
    # the name of the directory of the top-level git repo
    local canonical_dir="$(print -P '%1~')"
    if in_git_repo; then
        canonical_dir="$(basename "$(git rev-parse --show-toplevel)")"
    fi
    print -f '\e]1;%s\a' "$(basename $canonical_dir)"

    # prompt banner
    _print_prompt_header
}

function preexec {
    local input=$3

    if [[ -z $input ]]; then
        return
    fi

    # get starting time
    __ZSH_TIMESTAMP_BEGIN_PREV_CMD="$(__get_time)"

    # show starting time
    _print_time --fill '┈' --fill-color=237
}

export PROMPT="$ "

############### zsh-syntax-highlighting ###############

source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

typeset -A ZSH_HIGHLIGHT_STYLES

ZSH_HIGHLIGHT_STYLES[globbing]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=cyan'

############### fzf ###############

source /usr/local/opt/fzf/shell/completion.zsh
source /usr/local/opt/fzf/shell/key-bindings.zsh

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"

############### volta ###############

export VOLTA_HOME="${HOME}/.volta"
export PATH="${VOLTA_HOME}/bin:${PATH}"
