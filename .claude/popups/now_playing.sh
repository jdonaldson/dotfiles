#!/bin/bash
# Now playing from Spotify — truncated to fit status bar

if ! pgrep -xq Spotify; then
    exit 0
fi

artist=$(osascript -e 'tell application "Spotify" to artist of current track' 2>/dev/null)
track=$(osascript -e 'tell application "Spotify" to name of current track' 2>/dev/null)
state=$(osascript -e 'tell application "Spotify" to player state as string' 2>/dev/null)

[ -z "$track" ] && exit 0

# Truncate long names
[ ${#artist} -gt 15 ] && artist="${artist:0:14}…"
[ ${#track} -gt 20 ] && track="${track:0:19}…"

if [ "$state" = "playing" ]; then
    printf '▶ %s' "$artist - $track"
else
    printf '⏸ %s' "$artist - $track"
fi
