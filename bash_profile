#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
if [[ -h $SOURCE ]]; then
    SOURCE="$(readlink $SOURCE)"
fi
cd "$(dirname $SOURCE)"

for component in $(ls ./bash.d); do
    source ./bash.d/$component
done

PROMPT_COMMAND='pre_prompt; update_terminal_cwd'
PS1="$(get_prompt)"

check_ssh_agent
