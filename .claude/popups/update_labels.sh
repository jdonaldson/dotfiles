#!/bin/bash
# Compute icon + name for all panes, write to cache files.
# Called once per status refresh. Only writes if value changed (idempotent).
T=/opt/homebrew/bin/tmux
DIR="$HOME/.claude/popups/labels"

# Animation frame for Claude windows
frame=$(( $(date +%s) % 6 ))
claude_frames=( '✳' '✽' '✦' '✶' '✴' '✹' )
claude_icon="${claude_frames[$frame]}"

SEP=$'\x1f'  # unit separator
$T list-panes -a -F "#{pane_pid}${SEP}#{pane_current_command}${SEP}#{pane_title}${SEP}#{b:pane_current_path}" | \
while IFS="$SEP" read -r pid cmd title dirbase; do
  # Determine icon
  case "$title" in
    *[Cc]laude*) icon="$claude_icon" ;;
    *[Nn]vim*|*[Vv]im*) icon=$'\ue62b' ;;
    *)
      case "$cmd" in
        claude*)           icon="$claude_icon" ;;
        python*|ipython)   icon=$'\ue73c' ;;
        nvim|vim|vi)       icon=$'\ue62b' ;;
        node|npm|npx|bun)  icon=$'\ue718' ;;
        docker*|podman)    icon=$'\uf308' ;;
        git)               icon=$'\ue702' ;;
        ssh|scp|mosh)      icon=$'\uf489' ;;
        make|task|just)    icon=$'\uf085' ;;
        cargo|rustc)       icon=$'\ue7a8' ;;
        R|Rscript)         icon=$'\uf25d' ;;
        go)                icon=$'\ue724' ;;
        psql|mysql|sqlite3) icon=$'\uf1c0' ;;
        htop|top|btop)     icon=$'\uf200' ;;
        man|less|more)     icon=$'\uf02d' ;;
        [0-9]*)            icon="$claude_icon" ;;
        *)                 icon=$'\ue795' ;;
      esac
      ;;
  esac

  # Determine name: strip spinner, then check if generic
  name=$(printf '%s' "$title" | sed 's/^[⠐⠂⠄⠈✳✽✦✶✴✹ ]*//')
  case "$name" in
    ""|"~"|zsh|bash|"Claude Code") name="$dirbase" ;;
  esac

  label="$icon $name"
  file="$DIR/$pid"

  # Only write if changed
  [ -f "$file" ] && [ "$(cat "$file")" = "$label" ] && continue
  printf '%s' "$label" > "$file"
done

exit 0
