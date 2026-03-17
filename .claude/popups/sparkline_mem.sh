#!/bin/bash
# Memory sparkline for tmux status bar

HIST="/tmp/tmux_sparkline_mem.dat"
BARS=( ▁ ▂ ▃ ▄ ▅ ▆ ▇ █ )
COLS=$(tmux display-message -p '#{client_width}' 2>/dev/null || echo 200)
if (( COLS < 120 )); then WIDTH=3
elif (( COLS < 180 )); then WIDTH=5
else WIDTH=10; fi

# Get memory pressure percentage (fast on macOS)
pct=$(memory_pressure 2>/dev/null | awk '/percentage used:/ {gsub(/%/,""); print $NF; exit}')
[ -z "$pct" ] && pct=0

echo "$pct" >> "$HIST"
tail -n "$WIDTH" "$HIST" > "${HIST}.tmp" && mv "${HIST}.tmp" "$HIST"

spark=""
while read -r val; do
    idx=$(( val * 7 / 100 ))
    (( idx > 7 )) && idx=7
    (( idx < 0 )) && idx=0
    spark="${spark}${BARS[$idx]}"
done < "$HIST"

printf '%s' "$spark"
