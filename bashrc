#!/bin/bash

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

source /etc/bashrc

function source_bashd() {
    local component
    for component in $(ls ~/.bash.d); do
        source ~/.bash.d/$component
    done
}
source_bashd

if [[ $SHLVL == "1" ]]; then
    PROMPT_COMMAND='pre_prompt; update_terminal_cwd'
else
    PROMPT_COMMAND='display_code; printf "\n"; update_terminal_cwd'
fi

PS1="$(get_prompt)"

check_ssh_agent
