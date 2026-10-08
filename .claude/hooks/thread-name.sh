#!/usr/bin/env bash
# SessionStart hook: one name per work thread, everywhere.
#
# The thread name (kebab-case, same as <project>/.resume/<thread>.md) should be the session's name
# (prompt box, /resume picker, cross-session address), its tmux pane label, and its resume file.
# Set it at launch with `ct <thread>` (~/bin/ct, wraps `claude -n`), or in-session with `/rename <thread>`.
#
#   named    -> pin the tmux pane label to it (survives the spinner's pane_title race) and point
#               Claude at the resume file if one exists.
#   worktree -> unnamed, but cwd is a linked git worktree: name the session after the worktree
#               directory via sessionTitle (same effect as /rename), then treat it as named.
#   unnamed  -> warn the user, and tell Claude to ask for the thread before substantive work.
#
# Hooks cannot prompt, so asking is delegated to Claude via additionalContext. Limitation: a
# mid-session /rename does not re-run this hook, so the tmux label catches up on the next resume.
set -u

input=$(cat)
field() { printf '%s' "$input" | jq -r "$1 // empty"; }
title=$(field .session_title)
source=$(field .source)
cwd=$(field .cwd)

# clear/compact keep the session's existing name; nothing to do.
case "$source" in clear|compact) exit 0 ;; esac

# A linked worktree names its own thread: its git-dir differs from the shared common dir.
set_title=""
if [ -z "$title" ]; then
  gd=$(git -C "$cwd" rev-parse --absolute-git-dir 2>/dev/null || true)
  cd_=$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir 2>/dev/null || true)
  if [ -n "$gd" ] && [ "$gd" != "$cd_" ]; then
    wt=$(basename "$(git -C "$cwd" rev-parse --show-toplevel)" | tr '[:upper:]_' '[:lower:]-')
    if [[ $wt =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then title=$wt; set_title=$wt; fi
  fi
fi

if [ -n "$title" ]; then
  if [ -n "${TMUX_PANE:-}" ]; then
    pid=$(tmux display-message -p -t "$TMUX_PANE" '#{pane_pid}' 2>/dev/null || true)
    if [ -n "$pid" ]; then
      mkdir -p "$HOME/.claude/popups/labels"
      printf '%s\n' "$title" > "$HOME/.claude/popups/labels/$pid.override"
    fi
  fi
  resume="$cwd/.resume/$title.md"
  if [ -f "$resume" ]; then
    ctx="Thread: $title. Its resume file exists at $resume; read it and acknowledge it before starting work."
  else
    ctx="Thread: $title. No resume file yet at $resume; create it at shutdown."
  fi
  jq -n --arg c "$ctx" --arg t "$set_title" \
    '{hookSpecificOutput: ({hookEventName: "SessionStart", additionalContext: $c}
                           + (if $t == "" then {} else {sessionTitle: $t} end))}'
  exit 0
fi

recent=$(ls -t "$cwd/.resume" 2>/dev/null | sed -n 's/\.md$//p' | head -8 | paste -sd, - | sed 's/,/, /g')
recent=${recent:-none}
ctx="This session has NO thread name, so other sessions see an opaque default name and its tmux label collapses with others in the same directory. Before substantive work, ask the user which thread this is (recent threads here: $recent) and have them run /rename <thread>. Thread names are kebab-case and match .resume/<thread>.md."
msg="No thread name. Run /rename <thread> (recent here: $recent), or launch with: ct <thread>"
jq -n --arg c "$ctx" --arg m "$msg" \
  '{systemMessage: $m, hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $c}}'
