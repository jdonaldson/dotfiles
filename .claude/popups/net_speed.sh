#!/bin/bash
# Network activity glyph for the tmux status bar: one ▀ cell, top half (fg)
# colored by download rate, bottom half (bg) by upload rate, on a log-spaced
# heat ramp. Rate = en0 byte-counter delta / elapsed seconds, so it stays
# accurate as the adaptive status-interval stretches from 1s to 10s.

PREV="/tmp/tmux_net_speed_prev.dat"

read -r rx tx <<< "$(netstat -ib -I en0 2>/dev/null | awk 'NR==2 {print $7, $10}')"
rx=${rx:-0}; tx=${tx:-0}
now=$(date +%s)

read -r prx ptx pt 2>/dev/null < "$PREV" || { prx=$rx; ptx=$tx; pt=$((now - 1)); }
prx=${prx:-$rx}; ptx=${ptx:-$tx}; pt=${pt:-$((now - 1))}
echo "$rx $tx $now" > "$PREV"

dt=$(( now - pt )); (( dt < 1 )) && dt=1
drx=$(( (rx - prx) / dt )); (( drx < 0 )) && drx=0
dtx=$(( (tx - ptx) / dt )); (( dtx < 0 )) && dtx=0

# Log-ish heat ramp for the activity glyph; idle maps to the pill bg so the
# half fades out entirely.
heat() {
    local b=$1
    if   (( b <  2048 ));    then echo "#374145"
    elif (( b <  32768 ));   then echo "#717e5a"
    elif (( b <  262144 ));  then echo "#a7c080"
    elif (( b <  1048576 )); then echo "#dbbc7f"
    elif (( b <  4194304 )); then echo "#e69875"
    else                          echo "#e67e80"
    fi
}

# Two-color activity cell: ▀ top half (fg) = download, bottom half (bg) =
# upload. bg must be reset to the pill color afterward or it bleeds.
printf '#[fg=%s,bg=%s]▀#[fg=#e69875,bg=#374145]' "$(heat "$drx")" "$(heat "$dtx")"
