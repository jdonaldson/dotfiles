#!/bin/bash
# CPU sparkline for tmux status bar
# Samples CPU %, stores history, outputs sparkline characters

HIST="/tmp/tmux_sparkline_cpu.dat"
BARS=( ▁ ▂ ▃ ▄ ▅ ▆ ▇ █ )
WIDTH=10
NCPU=$(sysctl -n hw.ncpu 2>/dev/null || echo 8)
MAX=$((NCPU * 100))

# Sample current total CPU usage
cpu=$(ps -A -o %cpu= | awk '{s+=$1} END {printf "%.0f", s}')

# Append to history
echo "$cpu" >> "$HIST"

# Keep only last WIDTH values
tail -n "$WIDTH" "$HIST" > "${HIST}.tmp" && mv "${HIST}.tmp" "$HIST"

# Read values and render sparkline
spark=""
while read -r val; do
    idx=$(( val * 7 / MAX ))
    (( idx > 7 )) && idx=7
    (( idx < 0 )) && idx=0
    spark="${spark}${BARS[$idx]}"
done < "$HIST"

printf '%s' "$spark"
