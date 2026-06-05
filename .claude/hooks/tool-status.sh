#!/bin/bash
# Update tmux pane status based on Claude Code tool activity
# Hooks: PreToolUse (set tool status), Notification (alert sound),
#        PreCompact/Stop/SessionEnd (lifecycle markers + sounds)

# Skip if not in tmux
[ -z "$TMUX" ] && exit 0

STATUS_SCRIPT="$HOME/.claude/popups/pane_status.sh"
INPUT=$(cat)
EVENT=$(echo "$INPUT" | /usr/bin/jq -r '.hook_event_name // empty')
TOOL=$(echo "$INPUT" | /usr/bin/jq -r '.tool_name // empty')

case "$EVENT" in
  PreToolUse)
    # Don't overwrite ♻️ — compaction may still be running
    pane_pid=$(/opt/homebrew/bin/tmux display-message -t "${TMUX_PANE:-}" -p '#{pane_pid}')
    cur=$(cat "$HOME/.claude/popups/status/$pane_pid" 2>/dev/null)
    if [ "$cur" != "♻️" ]; then
      case "$TOOL" in
        Read|Glob|Grep)          bash "$STATUS_SCRIPT" read ;;
        Edit|Write|NotebookEdit) bash "$STATUS_SCRIPT" edit ;;
        Bash)                    bash "$STATUS_SCRIPT" burn ;;
        Task|WebFetch|WebSearch) bash "$STATUS_SCRIPT" wait ;;
      esac
    fi
    ;;
  Notification)
    /usr/bin/afplay -v 0.3 "$HOME/.config/kitty/bells/ahem.wav" &
    ;;
  PreCompact)
    bash "$STATUS_SCRIPT" compress
    /usr/bin/afplay -v 0.3 "$HOME/.config/kitty/bells/paper-crumple.wav" &
    ;;
  Stop)
    pane_pid=$(/opt/homebrew/bin/tmux display-message -t "${TMUX_PANE:-}" -p '#{pane_pid}')
    status_file="$HOME/.claude/popups/status/$pane_pid"
    cur=$(cat "$status_file" 2>/dev/null)
    if [ "$cur" = "♻️" ]; then
      # Check mtime: fresh = still compacting, old = compaction done
      elapsed=$(( $(date +%s) - $(stat -f %m "$status_file") ))
      if [ $elapsed -ge 5 ]; then
        bash "$STATUS_SCRIPT" alert  # compaction done → 🔔
      fi
      # else: just set by PreCompact, leave it
    else
      bash "$STATUS_SCRIPT" pencil
    fi
    ;;
  SessionEnd)
    bash "$STATUS_SCRIPT" clear
    /usr/bin/afplay -v 0.3 "$HOME/.config/kitty/bells/book-close.wav" &
    ;;
esac

exit 0
