#!/bin/bash
# Block heredocs that carry a SCRIPT body.
#
# The Bash-tool transport escapes `!` to `\!` inside heredoc bodies — even with a
# single-quoted delimiter (<<'EOF') and even with zsh histexpand off (set +H). It
# is a transport-level rewrite, NOT shell history expansion, so no shell option
# fixes it. The result silently corrupts Python/shell ("SyntaxError: unexpected
# character after line continuation character"). The reliable path is the Write
# tool, which bypasses shell string-parsing entirely.
#
# This hook denies a Bash command when it contains a heredoc (<<) AND that heredoc
# is feeding a script — either redirected to a code-file extension or piped into a
# code interpreter. Plain `cat <<EOF > notes.txt` / `<<EOF` to data files still works.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command') || exit 0
[ -z "$COMMAND" ] || [ "$COMMAND" = "null" ] && exit 0

deny() {
  jq -n --arg r "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $r
    }
  }'
  exit 0
}

REASON="Blocked: heredoc carrying a script body. The Bash tool escapes \`!\` to \`\\!\` inside heredoc bodies (transport-level — single-quoted delimiters and \`set +H\` do NOT help), which corrupts Python/shell. Use the Write tool to create the script file, then run it with Bash."

# Has a heredoc operator?
if echo "$COMMAND" | grep -qE '<<-?[[:space:]]*'\''?"?[A-Za-z_]'; then
  # ...redirected to a code-file extension?
  if echo "$COMMAND" | grep -qiE '>[[:space:]]*[^|&;]*\.(py|sh|bash|zsh|js|mjs|cjs|ts|rb|pl|lua|php|r)\b'; then
    deny "$REASON"
  fi
  # ...or piped into / fed to a code interpreter?
  if echo "$COMMAND" | grep -qE '(^|[|;&[:space:]])(python3?|node|deno|ruby|perl|Rscript|php|lua)([[:space:]]|$)'; then
    deny "$REASON"
  fi
fi

exit 0
