#!/bin/bash
# Memory percent-used readout for the tmux status bar.
# Activity-Monitor-style used = (active + wired + compressor) pages / hw.memsize.
# (memory_pressure's "free percentage" is pressure-based and sits near 92% on
# this 96GB machine even with 36GB in use — misleading as a utilization number.)

total=$(sysctl -n hw.memsize 2>/dev/null)
[ -z "$total" ] && { printf '?%%'; exit 0; }

used=$(vm_stat | awk -v total="$total" '
    /page size of/            { ps = $8 }
    /Pages active/            { a = $3 }
    /Pages wired/             { w = $4 }
    /occupied by compressor/  { c = $5 }
    END {
        gsub(/\./, "", a); gsub(/\./, "", w); gsub(/\./, "", c)
        printf "%.0f", (a + w + c) * ps / total * 100
    }')

if   (( used >= 85 )); then printf '#[fg=#e67e80]%d%%' "$used"
elif (( used >= 70 )); then printf '#[fg=#dbbc7f]%d%%' "$used"
else printf '%d%%' "$used"
fi
