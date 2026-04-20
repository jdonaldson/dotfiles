#!/usr/bin/env bash
# Claude Code status line script
# Displays: API mode (Bedrock/API) | model | cwd | context usage

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Shorten home directory
cwd="${cwd/#$HOME/~}"

# Determine API mode indicator
if [ "$CLAUDE_CODE_USE_BEDROCK" = "1" ]; then
  # Bedrock mode - show AWS profile and region
  api_indicator="🔷"
  api_label="Bedrock"

  if [ -n "$AWS_PROFILE" ]; then
    api_label="$api_label:$AWS_PROFILE"
    if [ -n "$AWS_REGION" ]; then
      api_label="$api_label@$AWS_REGION"
    fi
  fi
else
  # Anthropic API mode
  api_indicator="🟠"
  api_label="API"
fi

# Build context segment
if [ -n "$used_pct" ]; then
  used_int=${used_pct%.*}
  ctx_str="${used_int}% ctx"
else
  ctx_str="ctx: --"
fi

printf "\033[38;5;75m%s %s\033[0m  %s  \033[38;5;245m%s\033[0m  \033[38;5;172m%s\033[0m" \
  "$api_indicator" "$api_label" "$model" "$cwd" "$ctx_str"
