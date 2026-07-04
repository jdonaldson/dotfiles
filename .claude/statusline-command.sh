#!/usr/bin/env bash
# Claude Code status line script
# Displays: API mode (Bedrock/API) | model | cwd | 🧠 context | ⏳ 5h quota | 📅 7d quota
# Percentages are colored by severity: green <50, yellow 50-79, red >=80.

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
quota_5h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
quota_7d=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# Current git branch of the working directory (empty if not a repo)
branch=$(git -C "$cwd" branch --show-current 2>/dev/null)

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

# Severity color for a usage percentage: green <50, yellow 50-79, red >=80
pct_color() {
  local p=${1%.*}
  if [ "$p" -ge 80 ]; then
    echo "203"
  elif [ "$p" -ge 50 ]; then
    echo "179"
  else
    echo "114"
  fi
}

printf "\033[38;5;75m%s %s\033[0m  %s  \033[38;5;245m%s\033[0m" \
  "$api_indicator" "$api_label" "$model" "$cwd"

# 🌿 git branch of the working directory
if [ -n "$branch" ]; then
  printf "  \033[38;5;114m🌿%s\033[0m" "$branch"
fi

# 🧠 context window
if [ -n "$used_pct" ]; then
  used_int=${used_pct%.*}
  printf "  🧠\033[38;5;%sm%s%%\033[0m" "$(pct_color "$used_int")" "$used_int"
else
  printf "  🧠\033[38;5;245m--\033[0m"
fi

# ⏳ 5-hour quota window
if [ -n "$quota_5h" ]; then
  printf "  ⏳\033[38;5;%sm%s%%\033[0m" "$(pct_color "$quota_5h")" "${quota_5h%.*}"
fi

# 📅 7-day quota window
if [ -n "$quota_7d" ]; then
  printf "  📅\033[38;5;%sm%s%%\033[0m" "$(pct_color "$quota_7d")" "${quota_7d%.*}"
fi
