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

# Adaptive refresh: slow down when idle, stay fast when CPU hot
idle=$(tmux display-message -p '#{client_idle}')
current=$(tmux show -gv status-interval 2>/dev/null)
load=$(( cpu * 100 / MAX ))

if (( load > 50 )); then
  target=1
elif (( idle > 1200 )); then
  target=10
elif (( idle > 600 )); then
  target=5
elif (( idle > 300 )); then
  target=3
elif (( idle > 120 )); then
  target=2
else
  target=1
fi

if [[ "$current" != "$target" ]]; then
  tmux set -g status-interval "$target" >/dev/null 2>&1
fi
