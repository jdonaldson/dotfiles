#!/bin/bash
# Cached weather for tmux status bar — updates every 15 minutes

CACHE="/tmp/tmux_weather.txt"
MAX_AGE=900  # 15 minutes

# Use cache if fresh
if [ -f "$CACHE" ]; then
    age=$(( $(date +%s) - $(stat -f %m "$CACHE") ))
    if (( age < MAX_AGE )); then
        cat "$CACHE"
        exit 0
    fi
fi

# Fetch compact weather (format: emoji + temp)
result=$(curl -s --max-time 3 "wttr.in/?format=%c%t" 2>/dev/null | tr -d '+')

if [ -n "$result" ] && ! echo "$result" | grep -q "Unknown"; then
    echo "$result" > "$CACHE"
    printf '%s' "$result"
fi
