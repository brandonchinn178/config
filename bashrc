#!/bin/bash

source /etc/bashrc

function get_here() {
    local SOURCE="${BASH_SOURCE[0]}"
    if [[ -L "$SOURCE" ]]; then
        dirname $(readlink "$SOURCE")
    else
        dirname "$SOURCE"
    fi
}
HERE=$(get_here)

function source_bashd() {
    local component
    for component in $(find "$HERE/bash.d" -type f); do
        source $component
    done
}
source_bashd

# If not running interactively, exit here
case $- in
    *i*) ;;
      *) return;;
esac

if [[ $SHLVL == "1" ]]; then
    PROMPT_COMMAND='pre_prompt; update_terminal_cwd'
else
    PROMPT_COMMAND='display_code; printf "\n"; update_terminal_cwd'
fi

PS1="$ "

# If a `venv` directory is in the current directory on start up, source it.
if [[ -d venv ]]; then
    source venv/bin/activate
fi
