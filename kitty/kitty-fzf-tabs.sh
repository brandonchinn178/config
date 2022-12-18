#!/usr/bin/env sh

all_tabs="$(
    kitty @ ls | jq -r '
        .[]
        | select(.is_active)
        | .tabs[]
        | select(.title != "Tab selection")
        | [.title, "id:\(.id)"]
        | @tsv
    ' | column -ts $'\t'
)"

new_tab_id="$(fzf --reverse <<< "${all_tabs}" | awk '{ print $2 }')"
kitty @ focus-tab -m "${new_tab_id}"
