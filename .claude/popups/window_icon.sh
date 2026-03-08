#!/bin/bash
# Map running command or pane title to a Nerd Font / Unicode icon
# Animated icons cycle based on current time
# $1 = pane_current_command, $2 = pane_title (optional)
cmd="$1"
title="$2"

# Animation frame based on current second
frame=$(( $(date +%s) % 6 ))

# Animated sparkle cycle for Claude
claude_frames=( '✳' '✽' '✦' '✶' '✴' '✹' )
claude_icon() { printf '%s' "${claude_frames[$frame]}"; }

# Check pane title first
case "$title" in
    *[Cc]laude*)       claude_icon; exit ;;
    *[Nn]vim*|*[Vv]im*) printf '\ue62b'; exit ;;
esac

# Fall back to command name
case "$cmd" in
    claude*)        claude_icon ;;
    python*|ipython) printf '\ue73c' ;;
    nvim|vim|vi)    printf '\ue62b' ;;
    node|npm|npx|bun) printf '\ue718' ;;
    docker*|podman) printf '\uf308' ;;
    git)            printf '\ue702' ;;
    ssh|scp|mosh)   printf '\uf489' ;;
    make|task|just) printf '\uf085' ;;
    cargo|rustc)    printf '\ue7a8' ;;
    R|Rscript)      printf '\uf25d' ;;
    ruby|irb)       printf '\ue739' ;;
    go)             printf '\ue724' ;;
    java|kotlin*)   printf '\ue738' ;;
    psql|mysql|sqlite3) printf '\uf1c0' ;;
    htop|top|btop)  printf '\uf200' ;;
    man|less|more)  printf '\uf02d' ;;
    zsh|bash|fish)  printf '\ue795' ;;
    [0-9]*)         claude_icon ;;
    *)              printf '\ue795' ;;
esac
