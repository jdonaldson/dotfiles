#!/bin/bash
# Set status-left and status-right based on terminal width
# Called from tmux hooks: client-resized, session-created
COLS=$(tmux display-message -p '#{client_width}' 2>/dev/null || echo 200)

# Nerd Font icons
SLACK=$'\uf198'
CPU=$'\uf2db'
WIFI=$'\uf1eb'
MEM=$'\uf233'
SPOTIFY=$'\uf1bc'
PL=$'\ue0b6'  # powerline left half circle
PR=$'\ue0b4'  # powerline right half circle

# Spotify section: only include if Spotify is running
if pgrep -xq Spotify; then
    SPOTIFY_SEC="#[fg=#374145,bg=default]${PL}#[range=user|spotify]#[fg=#1DB954,bg=#374145] ${SPOTIFY} #[fg=#d699b6]#(bash ~/.claude/popups/now_playing.sh) #[norange]#[fg=#374145,bg=default]${PR} "
else
    SPOTIFY_SEC=""
fi

# Resource sections (always shown)
RESOURCES="#[fg=#374145,bg=default]${PL}#[bg=#374145]#[range=user|slack]#[fg=#e67e80,bg=#374145] ${SLACK}#[fg=#d3c6aa] #(bash ~/.claude/popups/slack_unread.sh) #[norange]#[fg=#4f5b58]⡇ #[range=user|cpu]#[fg=#a7c080]${CPU} #(bash ~/.claude/popups/sparkline.sh)#[norange] #[fg=#4f5b58]⡇ #[range=user|net]#[fg=#e69875]${WIFI} #(bash ~/.claude/popups/sparkline_net.sh)#[norange] #[fg=#4f5b58]⡇ #[range=user|mem]#[fg=#7fbbb3]${MEM} #(bash ~/.claude/popups/sparkline_mem.sh)#[norange] #[fg=#4f5b58]⡇"

# Time pill (always shown)
TIME_PILL="#[fg=#374145,bg=default]${PR} #[fg=#7fbbb3,bg=default]${PL}#[fg=#232a2e,bg=#7fbbb3,bold]"

if (( COLS >= 180 )); then
    tmux set -g status-left \
        "#(bash ~/.claude/popups/update_labels.sh >/dev/null)#[fg=#a7c080,bg=default]${PL}#[bg=#a7c080,fg=#232a2e,bold] 🐸 #S #[fg=#a7c080,bg=#374145]${PR}#[fg=#d3c6aa,bg=#374145] 💻 #h #[fg=#374145,bg=default]${PR} "
    tmux set -g status-right \
        "${SPOTIFY_SEC}${RESOURCES} #[fg=#dbbc7f]#(bash ~/.claude/popups/weather.sh) #[fg=#4f5b58]⡇ #[fg=#859289] %d %b ${TIME_PILL} #(bash ~/.claude/popups/clock_emoji.sh) %I:%M%p #[fg=#7fbbb3,bg=default]${PR} "
else
    tmux set -g status-left \
        "#(bash ~/.claude/popups/update_labels.sh >/dev/null)#[fg=#a7c080,bg=default]${PL}#[bg=#a7c080,fg=#232a2e,bold] 🐸 #[fg=#a7c080,bg=default]${PR} "
    tmux set -g status-right \
        "${SPOTIFY_SEC}${RESOURCES} #[fg=#859289] %d %b ${TIME_PILL} %I:%M%p #[fg=#7fbbb3,bg=default]${PR} "
fi
