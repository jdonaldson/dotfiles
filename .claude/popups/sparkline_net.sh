#!/bin/bash
# Network activity sparkline for tmux status bar
# Tracks bytes delta between samples

HIST="/tmp/tmux_sparkline_net.dat"
PREV="/tmp/tmux_sparkline_net_prev.dat"
BARS=( ▁ ▂ ▃ ▄ ▅ ▆ ▇ █ )
WIDTH=10

# Get current total bytes (in + out) on en0
read -r bytes_in bytes_out <<< "$(netstat -ib -I en0 2>/dev/null | awk 'NR==2 {print $7, $10}')"
now=$(( ${bytes_in:-0} + ${bytes_out:-0} ))

# Calculate delta from previous sample
prev=$(cat "$PREV" 2>/dev/null || echo "$now")
echo "$now" > "$PREV"
delta=$(( now - prev ))
(( delta < 0 )) && delta=0

# Convert to KB/s
kb=$(( delta / 1024 ))

echo "$kb" >> "$HIST"
tail -n "$WIDTH" "$HIST" > "${HIST}.tmp" && mv "${HIST}.tmp" "$HIST"

# Auto-scale: use max from recent history
max=$(sort -rn "$HIST" | head -1)
(( max < 10 )) && max=10

spark=""
while read -r val; do
    idx=$(( val * 7 / max ))
    (( idx > 7 )) && idx=7
    (( idx < 0 )) && idx=0
    spark="${spark}${BARS[$idx]}"
done < "$HIST"

printf '%s' "$spark"
