#!/bin/bash
# Rename tmux windows intelligently:
# - If pane has a specific title (not generic "Claude Code"), use it
# - If window name is generic/spinner, fall back to directory basename
# Uses a lock file to prevent recursive hook loops
T=/opt/homebrew/bin/tmux
LOCK="/tmp/refresh_windows.lock"

# Prevent infinite loop from window-renamed hook
if [ -f "$LOCK" ]; then exit 0; fi
touch "$LOCK"
trap 'rm -f "$LOCK"' EXIT
set +e

for idx in $($T list-windows -F '#{window_index}'); do
  # Check pane title first (strip spinner chars)
  title=$($T display-message -t ":${idx}.1" -p '#{pane_title}' | sed 's/^[⠐⠂⠄⠈✳ ]*//')

  # If pane title is specific, use it
  case "$title" in
    "Claude Code"|""|"~"|"zsh"|"bash") ;;
    *) $T rename-window -t ":${idx}" "$title"; continue ;;
  esac

  # Otherwise, check if window name is generic/spinner — replace with directory
  wname=$($T display-message -t ":${idx}" -p '#{window_name}')
  case "$wname" in
    ""|*"Claude Code"*|"2.1"*)
      path=$($T display-message -t ":${idx}.1" -p '#{pane_current_path}')
      dirname="${path##*/}"
      case "$dirname" in
        ""|"~"|"Projects") dirname="$($T display-message -t ":${idx}" -p '#S'):${idx}" ;;
      esac
      $T rename-window -t ":${idx}" "$dirname"
      ;;
  esac
done
exit 0
