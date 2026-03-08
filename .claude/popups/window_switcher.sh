#!/bin/bash
# Window switcher popup — anchored to bottom-left, near where output streams

pw=30
ph=10

tmux display-popup -x 4 -y S -w "$pw" -h "$ph" -E \
    "tmux list-windows -F '#{window_index}: #{?window_active,▸ , }#{window_name}' \
    | fzf --reverse --cycle --no-info --prompt='› ' \
    | cut -d: -f1 \
    | xargs -I{} tmux select-window -t :{}"
