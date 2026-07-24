#!/bin/bash
# Slow (~8s) Wi-Fi probe. Run in the BACKGROUND off the status refresh path;
# one system_profiler call feeds two caches read instantly by the status bar:
#   tmux_wifi_sn.dat        "<signal> <noise>" (dBm, "NA NA" when disconnected)
#   tmux_wifi_spectrum.dat  "CUR|OTH <chan> <band-GHz> <width-MHz>" per visible AP
# macOS removed `airport`; system_profiler is the only unprivileged source.
CACHE="${TMPDIR:-/tmp}/tmux_wifi_sn.dat"
SPEC="${TMPDIR:-/tmp}/tmux_wifi_spectrum.dat"

out=$(system_profiler SPAirPortDataType 2>/dev/null)

line=$(printf '%s\n' "$out" | grep -m1 "Signal / Noise")
# "Signal / Noise: -73 dBm / -97 dBm" -> first number = signal, second = noise
read -r sig noise _ < <(printf '%s\n' "$line" | grep -oE -- '-?[0-9]+' | tr '\n' ' ')
printf '%s %s\n' "${sig:-NA}" "${noise:-NA}" > "$CACHE"

# First Channel line is the current network's -- but only when connected
# (otherwise the scan list starts immediately and NR==1 is a neighbor).
printf '%s\n' "$out" | grep -oE 'Channel: [0-9]+ \([0-9.]+GHz, [0-9]+MHz\)' | \
  awk -v connected="${sig:-NA}" '
    { gsub(/[():,]/, " "); gsub(/GHz|MHz/, "")
      tag = (NR == 1 && connected != "NA") ? "CUR" : "OTH"
      print tag, $2, $3, $4 }' > "$SPEC"
