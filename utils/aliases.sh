#!/bin/bash

BASHRC="$HOME/.bashrc"

add_alias() {
    local alias_line="$1"
    if ! grep -qF "$alias_line" "$BASHRC"; then
        echo "$alias_line" >> "$BASHRC"
        echo "Added: $alias_line"
    else
        echo "Already present: $alias_line"
    fi
}

add_alias "alias lh='ls -lh'"
add_alias "alias getchmod='stat -c \"%a %n\"'"

echo "Done. Run: source ~/.bashrc"
