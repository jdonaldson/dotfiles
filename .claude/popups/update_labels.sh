#!/bin/bash
# Compute icon + name for all panes, write to cache files.
# Called once per status refresh. Only writes if value changed (idempotent).
T=/opt/homebrew/bin/tmux
DIR="$HOME/.claude/popups/labels"

claude_icon=''

SEP=$'\x1f'  # unit separator
$T list-panes -a -F "#{pane_pid}${SEP}#{pane_current_command}${SEP}#{pane_title}${SEP}#{b:pane_current_path}${SEP}#{pane_current_path}" | \
while IFS="$SEP" read -r pid cmd title dirbase dirfull; do
  # Determine icon — check title first, then process tree, then command
  case "$title" in
    *[Cc]laude*) icon="$claude_icon" ;;
    *[Nn]vim*|*[Vv]im*) icon=$'\ue62b' ;;
    *)
      # Check if pane has a claude child process (catches startup before title is set)
      if pgrep -P "$pid" -f claude >/dev/null 2>&1; then
        icon="$claude_icon"
      else
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
      fi
      ;;
  esac

  # Determine name: strip spinner, then check if generic
  name=$(printf '%s' "$title" | sed 's/^[⠐⠂⠄⠈✳✽✦✶✴✹ ]*//')
  case "$name" in
    ""|"~"|zsh|bash|"Claude Code")
      # Generic title — fall back to a path-derived label.
      # Use the last two non-empty components of the full path so panes
      # rooted at a shared parent (e.g. ~/Projects/work/{curvo,vespa,...})
      # get distinguishable labels. Fall back to dirbase if there isn't
      # a meaningful parent (e.g. cwd is /, ~, or a single-level dir).
      parent=$(dirname "$dirfull")
      parentbase=$(basename "$parent")
      case "$parent" in
        /|.|"")             name="$dirbase" ;;
        "$HOME")            name="$dirbase" ;;
        *)                  name="$parentbase/$dirbase" ;;
      esac
      ;;
  esac

  # If a manual override exists for this pane, use it instead of the
  # computed label. Override file is "<DIR>/<pid>.override" — write to it
  # to pin a label, remove it to resume auto-labeling.
  override="$DIR/$pid.override"
  if [ -f "$override" ]; then
    name=$(cat "$override")
  fi

  label="$icon $name"
  file="$DIR/$pid"

  # Only write if changed
  [ -f "$file" ] && [ "$(cat "$file")" = "$label" ] && continue
  printf '%s' "$label" > "$file"
done

# Clean up label/status files for dead panes
LIVE_PIDS=$($T list-panes -a -F "#{pane_pid}" 2>/dev/null | sort -u)
for f in "$DIR"/*; do
  [ -f "$f" ] || continue
  basename=$(basename "$f")
  # Strip the .override suffix if present so we check against PIDs
  pid="${basename%.override}"
  if ! echo "$LIVE_PIDS" | grep -qx "$pid"; then
    rm -f "$f"
  fi
done

# Animate compress + transition stale sparkles
SDIR="$HOME/.claude/popups/status"
now=$(date +%s)
for f in "$SDIR"/*; do
  [ -f "$f" ] || continue
  cur=$(cat "$f")
  mtime=$(stat -f %m "$f")
  elapsed=$(( now - mtime ))
  case "$cur" in
    ♻️)
      if [ $elapsed -gt 300 ]; then
        printf '%s' "🔔" > "$f"
      fi
      ;;
    ✳|✽|✦|✶|✴|✹)
      if [ $elapsed -gt 5 ]; then
        printf '%s' "🔔" > "$f"
      fi
      ;;
  esac
done

# Clean up status files for dead panes
for f in "$SDIR"/*; do
  [ -f "$f" ] || continue
  pid=$(basename "$f")
  if ! echo "$LIVE_PIDS" | grep -qx "$pid"; then
    rm -f "$f"
  fi
done

exit 0
