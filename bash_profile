#!/bin/bash

function get_here() {
    local SOURCE="${BASH_SOURCE[0]}"
    if [[ -L "$SOURCE" ]]; then
        dirname $(readlink "$SOURCE")
    else
        dirname "$SOURCE"
    fi
}
HERE=$(get_here)
source "$HERE/bashrc"
