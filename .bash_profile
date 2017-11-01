#!/bin/bash

for component in $(ls ~/.bash.d); do
    source ~/.bash.d/$component
done

PROMPT_COMMAND='pre_prompt; update_terminal_cwd'
PS1="$(get_prompt)"

check_ssh_agent
