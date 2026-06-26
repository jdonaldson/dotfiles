#!/usr/bin/env python3
"""Per-core CPU braille meter for the tmux status bar.

Renders each logical core as a vertical braille bar (5 levels). Two cores share
one braille char (left/right column). On Apple Silicon the first 8 cores are the
performance cluster and the last 4 are efficiency, so they're drawn as two groups
split by a thin separator. Each char is colored by the hotter of its two cores.

Utilization is measured as the delta of cpu_times since the previous tick (state
persisted to a temp file), so it's non-blocking and reflects activity over the
status refresh interval. Emits tmux #[fg=...] format escapes; tmux expands those
in #() output. Set CORE_METER_NOCOLOR=1 for plain output.

  ~/.claude/popups/.venv/bin/python ~/.claude/popups/core_meter.py
"""
import json
import os
import sys

STATE = os.path.join(os.environ.get("TMPDIR", "/tmp"), "tmux_core_meter.json")
DOT = {"L": [0x40, 0x04, 0x02, 0x01], "R": [0x80, 0x20, 0x10, 0x08]}  # bottom->top
NCOLOR = bool(os.environ.get("CORE_METER_NOCOLOR"))

# everforest heat ramp (low -> maxed)
RAMP = [(25, "#717e5a"), (50, "#a7c080"), (75, "#dbbc7f"), (90, "#e69875"), (101, "#e67e80")]
SEP_FG = "#4f5b58"


def heat(pct):
    for hi, color in RAMP:
        if pct < hi:
            return color
    return RAMP[-1][1]


def bar_bits(pct, col):
    dots = min(4, int(pct / 100 * 4 + 0.5))
    return sum(DOT[col][i] for i in range(dots))


def colored(text, fg):
    return text if NCOLOR else f"#[fg={fg}]{text}"


def sample():
    """Per-core utilization (0..100) as delta vs the last tick."""
    import psutil
    cur = [(sum(t), t.idle) for t in psutil.cpu_times(percpu=True)]  # (total, idle)
    prev = None
    try:
        with open(STATE) as f:
            prev = json.load(f)
    except Exception:
        prev = None
    with open(STATE, "w") as f:
        json.dump(cur, f)
    if not prev or len(prev) != len(cur):
        return [0.0] * len(cur)
    out = []
    for (t1, i1), (t0, i0) in zip(cur, prev):
        dt, di = t1 - t0, i1 - i0
        out.append(0.0 if dt <= 0 else max(0.0, min(100.0, 100.0 * (1 - di / dt))))
    return out


def render(cores):
    out = ""
    for i in range(0, len(cores), 2):
        l = cores[i]
        r = cores[i + 1] if i + 1 < len(cores) else 0.0
        ch = chr(0x2800 + bar_bits(l, "L") + bar_bits(r, "R"))
        out += colored(ch, heat(max(l, r)))
    return out


def main():
    loads = sample()
    n = len(loads)
    # Apple Silicon: 8 P-cores then 4 E-cores. Fall back to a single group otherwise.
    if n == 12:
        strip = render(loads[:8]) + colored("·", SEP_FG) + render(loads[8:])
    else:
        strip = render(loads)
    sys.stdout.write(strip)


if __name__ == "__main__":
    main()
