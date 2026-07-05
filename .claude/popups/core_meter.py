#!/usr/bin/env python3
"""Per-core CPU braille meter for the tmux status bar.

Renders each logical core as a vertical braille bar with a 1-dot idle floor, so
the meter never reads as empty/broken at low load. Two cores share one braille
char (left/right column). On Apple Silicon the first 8 cores are the performance
cluster and the last 4 are efficiency, drawn as two groups split by a thin
separator and distinguished by baseline hue: idle P-cores green-grey, idle
E-cores blue-grey. Once either core in a char is active, the char is colored by
the hotter of the two via the heat ramp.

Also owns the adaptive status-interval logic (1s when CPU is hot or the client
is active, slowing to 10s when idle) so the status bar needs only one #() job
per tick for CPU.

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
P_IDLE = "#6b7a52"  # baseline hue, performance cluster (green-grey)
E_IDLE = "#57787e"  # baseline hue, efficiency cluster (blue-grey)


def heat(pct):
    for hi, color in RAMP:
        if pct < hi:
            return color
    return RAMP[-1][1]


def active_dots(pct):
    return min(4, int(pct / 100 * 4 + 0.5))


def bar_bits(pct, col):
    # 1-dot floor keeps idle cores visible as a baseline
    return sum(DOT[col][i] for i in range(max(1, active_dots(pct))))


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


def render(cores, idle_fg):
    out = ""
    for i in range(0, len(cores), 2):
        l = cores[i]
        r = cores[i + 1] if i + 1 < len(cores) else None
        bits = bar_bits(l, "L") + (bar_bits(r, "R") if r is not None else 0)
        hot = max(l, r or 0.0)
        fg = heat(hot) if active_dots(hot) else idle_fg
        out += colored(chr(0x2800 + bits), fg)
    return out


def adapt_interval(load_pct):
    """Tune tmux status-interval: 1s under load or active use, up to 10s idle."""
    import subprocess

    def tmux(*args):
        r = subprocess.run(["tmux", *args], capture_output=True, text=True, timeout=2)
        return r.stdout.strip()

    try:
        idle = int(float(tmux("display-message", "-p", "#{client_idle}") or 0))
        if load_pct > 50:
            target = 1
        elif idle > 1200:
            target = 10
        elif idle > 600:
            target = 5
        elif idle > 300:
            target = 3
        elif idle > 120:
            target = 2
        else:
            target = 1
        if tmux("show", "-gv", "status-interval") != str(target):
            tmux("set", "-g", "status-interval", str(target))
    except Exception:
        pass  # never let interval tuning break the meter output


def main():
    loads = sample()
    n = len(loads)
    # Apple Silicon: 8 P-cores then 4 E-cores. Fall back to a single group otherwise.
    if n == 12:
        strip = render(loads[:8], P_IDLE) + colored("·", SEP_FG) + render(loads[8:], E_IDLE)
    else:
        strip = render(loads, P_IDLE)
    sys.stdout.write(strip)
    sys.stdout.flush()
    adapt_interval(sum(loads) / n if n else 0.0)


if __name__ == "__main__":
    main()
