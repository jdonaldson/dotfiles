#!/bin/bash
# Play a page-flip sound mapped to the current tmux window
BELLS_DIR="$HOME/.config/kitty/bells"

idx=$(tmux display-message -p '#{window_index}' 2>/dev/null)
[ -z "$idx" ] && exit 0

# Map to 01-10
idx=$(( (idx % 10) + 1 ))
src=$(printf "%s/flip%02d.wav" "$BELLS_DIR" "$idx")

[ -f "$src" ] && /usr/bin/afplay "$src"
