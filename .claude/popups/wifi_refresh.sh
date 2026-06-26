#!/bin/bash
# Slow (~8s) Wi-Fi signal/noise probe. Run in the BACKGROUND off the status refresh
# path; writes "<signal> <noise>" (dBm, or "NA NA" when disconnected) to a cache file
# that wifi_meter.sh reads instantly. macOS removed `airport`; system_profiler is the
# only unprivileged source for RSSI/noise.
CACHE="${TMPDIR:-/tmp}/tmux_wifi_sn.dat"
line=$(system_profiler SPAirPortDataType 2>/dev/null | grep -m1 "Signal / Noise")
# "Signal / Noise: -73 dBm / -97 dBm" -> first number = signal, second = noise
read -r sig noise _ < <(printf '%s\n' "$line" | grep -oE -- '-?[0-9]+' | tr '\n' ' ')
printf '%s %s\n' "${sig:-NA}" "${noise:-NA}" > "$CACHE"
