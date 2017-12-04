#!/bin/bash

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

source /etc/bashrc

for component in $(ls ~/.bash.d); do
    source ~/.bash.d/$component
done

if [[ $SHLVL == "1" ]]; then
    PROMPT_COMMAND='pre_prompt; update_terminal_cwd'
fi

PS1="$(get_prompt)"

check_ssh_agent
