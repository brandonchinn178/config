#!/usr/bin/env zsh

############### Paths ###############

fpath=(
    ~/.zsh-completion
    $fpath
)

path+=~/.bin
path+=~/.local/bin

############### Tab completions ###############

autoload -Uz compinit && compinit

zstyle ':completion:*' menu select
zmodload zsh/complist
bindkey -M menuselect '^[[Z' reverse-menu-complete

# git tab completions
zstyle ':completion:*:*:git:*' script ~/.bash-completion/git-completion.bash

############### Key bindings ###############

bindkey '^R' history-incremental-search-backward
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^[b' vi-backward-word
bindkey '^[f' vi-forward-word
bindkey '^[^?' vi-backward-kill-word
bindkey '^W' backward-delete-word

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

############### Git helpers ###############

# Exit code 0 if currently in a git repo.
function in_git_repo {
    git rev-parse --is-inside-work-tree &> /dev/null
}

# Change directory to root of the git repo
function root {
    cd "$(git rev-parse --show-toplevel)"
}

############### Miscellaneous ###############

alias grep="grep --color"

function subl {
    local target=("$@")
    if [[ ${#target} == 0 ]]; then
        target+=.
    fi

    open -a 'Sublime Text' $target
}

export EDITOR=vim
eval "$(export_aws)"

############### Prompt ###############

zmodload zsh/datetime

function __get_time {
    strftime '%s.%N'
}

function __print_rjust {
    print -P -f '%*s' "${COLUMNS}" "$1"
}

# prints time on the right, then resets to start of line
function __print_time_rjust {
    # color commands wreck the right-justification, so right-justify it
    # first, then color it
    print -P -f %s '%F{230}' "$(__print_rjust '%D{%F %T} 🕰️')" '%f' $'\r'
}

__ZSH_TIMESTAMP_BEGIN_PREV_CMD=

function precmd {
    local retval=$?

    # if a previous command was run
    if [[ -n "${__ZSH_TIMESTAMP_BEGIN_PREV_CMD}" ]]; then
        # show ending time
        __print_time_rjust

        # get elapsed time
        local elapsed_time="$(print -f '%.4f' "$(( $(__get_time) - __ZSH_TIMESTAMP_BEGIN_PREV_CMD ))")"

        # show emoji based on exit code of last command
        local code_display
        case $retval in
            (0) code_display="👌" ;;
            (1) code_display="❗" ;;
            (*) code_display="❗%F{red}(code=${retval})%f" ;;
        esac
        print -P "${code_display} %F{250}(elapsed=${elapsed_time}s)%f"

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

    local prompt_parts=()

    if [[ $SHLVL -gt 1 ]]; then
        prompt_parts+="%F{yellow}{%L}%f"
    fi

    prompt_parts+="%F{green}%~%f"

    if in_git_repo; then
        local branch=$(git branch --show-current)
        local commit=$(git rev-parse --short=12 HEAD)
        prompt_parts+="%F{magenta}(${branch})@${commit}%f"
    fi

    print ''
    print -P -f '%s\r' "%F{237}${(r:${COLUMNS}::─:)}%f"
    print -P $prompt_parts ''
}

function preexec {
    local input=$3

    if [[ -z $input ]]; then
        return
    fi

    # get starting time
    __ZSH_TIMESTAMP_BEGIN_PREV_CMD="$(__get_time)"

    # show starting time
    __print_time_rjust
    local half_width="$(( COLUMNS / 2 ))"
    print -P "%F{237}${(r:$half_width::~:)}%f"
}

export PROMPT="$ "

############### zsh-syntax-highlighting ###############

source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
