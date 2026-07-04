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

# Validate: a real %c%t response is short, contains a degree sign, and has no
# HTML. This rejects captive-portal splash pages, error blobs, and "Unknown".
if [ -n "$result" ] \
    && [ "${#result}" -lt 30 ] \
    && [[ "$result" == *"°"* ]] \
    && [[ "$result" != *"<"* ]] \
    && ! echo "$result" | grep -qiE "unknown|html|redirect"; then
    echo "$result" > "$CACHE"
    printf '%s' "$result"
else
    # Bad fetch (e.g. captive portal): keep showing last-good cache, don't poison it
    [ -f "$CACHE" ] && cat "$CACHE"
fi
