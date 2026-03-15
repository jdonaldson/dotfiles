#!/bin/bash
# Set pane status emoji (persists independently of pane title)
# Usage: pane_status.sh <status> [description]
#   status: alert | compress | wait | burn | clear
STATUS_DIR="$HOME/.claude/popups/status"

case "$1" in
  alert)    icon="🔔" ;;
  spin)     icon="✳" ;;
  compress) icon="♻️" ;;
  wait)     icon="✳" ;;
  burn)     icon="✳" ;;
  read)     icon="✳" ;;
  edit)     icon="✳" ;;
  pencil)   icon="✏️" ;;
  input)    icon="⏳" ;;
  clear)    icon="" ;;
  *)        echo "Usage: pane_status.sh {alert|spin|compress|wait|burn|read|edit|input|clear}"; exit 1 ;;
esac

# Key by pane PID so it's stable and filename-safe
pane_pid=$(/opt/homebrew/bin/tmux display-message -p '#{pane_pid}')

if [ -z "$icon" ]; then
  rm -f "$STATUS_DIR/$pane_pid"
else
  echo -n "$icon" > "$STATUS_DIR/$pane_pid"
fi
