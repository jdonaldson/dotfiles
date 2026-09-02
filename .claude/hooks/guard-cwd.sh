#!/bin/bash
# Prevent Claude from moving/deleting the session's working directory.
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command') || exit 0
CWD=$(echo "$INPUT" | jq -r '.cwd') || exit 0

# Bail if jq returned nothing useful
[ -z "$COMMAND" ] || [ "$COMMAND" = "null" ] && exit 0
[ -z "$CWD" ] || [ "$CWD" = "null" ] && exit 0

# Escape CWD for use in regex (including - and ])
ESCAPED_CWD=$(printf '%s' "$CWD" | sed 's/[.[\*^$()+?{|/\-\]]/\\&/g')

# Check if command moves or removes the working directory itself (not files within it)
if echo "$COMMAND" | grep -qE "(mv|rm|trash)\s.*\s+$ESCAPED_CWD\s*$"; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Blocked: command would move/delete the working directory"
    }
  }'
  exit 0
fi

exit 0
