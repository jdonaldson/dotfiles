#!/usr/bin/env python3
"""Wi-Fi current-SNR indicator for the tmux status bar (one braille char).

Reads the signal/noise cache written by wifi_refresh.sh (instant). If the cache is
stale (> REFRESH_S) or missing, kicks off a DETACHED background refresh and renders
the last known value -- the ~8s system_profiler probe never blocks the status tick.

Render: one thick braille bar whose TWO columns can sit at slightly different
heights, so a single cell resolves 8 half-steps of SNR = signal - noise instead of
4 full-dot levels. Height alone encodes strength (no color ramp): the taller column
is ceil(level/2), the shorter floor(level/2), so odd levels read as a one-dot offset
between the columns. 1-dot floor while connected; dim blank when disconnected. Emits
a single steady foreground; set WIFI_METER_NOCOLOR=1 to strip the escape entirely.
"""
import os
import subprocess
import sys
import time

HOME = os.path.expanduser("~")
CACHE = os.path.join(os.environ.get("TMPDIR", "/tmp"), "tmux_wifi_sn.dat")
LOCK = CACHE + ".lock"
REFRESH = os.path.join(HOME, ".claude/popups/wifi_refresh.sh")
REFRESH_S = 20          # cache considered stale after this many seconds
NCOLOR = bool(os.environ.get("WIFI_METER_NOCOLOR"))
FG, DIM = "#d3c6aa", "#4f5b58"  # steady default-text fg; strength is height, not hue
DOT = {0: [0x40, 0x04, 0x02, 0x01], 1: [0x80, 0x20, 0x10, 0x08]}  # col%2 -> bottom->top


def col(text, fg):
    return text if NCOLOR else f"#[fg={fg}]{text}"


def read_cache():
    try:
        age = time.time() - os.path.getmtime(CACHE)
        with open(CACHE) as f:
            sig, noise = f.read().split()[:2]
        return age, sig, noise
    except Exception:
        return 1e9, "NA", "NA"


def maybe_refresh(age):
    if age <= REFRESH_S:
        return
    try:  # crude lock so concurrent ticks don't spawn a pile of probes
        if os.path.exists(LOCK) and time.time() - os.path.getmtime(LOCK) < 30:
            return
        open(LOCK, "w").close()
        subprocess.Popen(["bash", REFRESH], stdout=subprocess.DEVNULL,
                         stderr=subprocess.DEVNULL, start_new_session=True)
    except Exception:
        pass


def snr_bars(snr):
    """SNR -> 1..8 half-steps: one step per 5 dB from ~10 dB up to ~45 dB."""
    return max(1, min(8, round((snr - 5) / 5)))  # 1-dot floor while connected


def cell(level):
    """Braille char with left column ceil(level/2), right floor(level/2) dots tall."""
    left, right = (level + 1) // 2, level // 2
    bits = sum(DOT[0][r] for r in range(left)) | sum(DOT[1][r] for r in range(right))
    return chr(0x2800 + bits)


def main():
    age, sigs, noises = read_cache()
    maybe_refresh(age)
    if sigs == "NA":
        sys.stdout.write(col("⠀", DIM))  # blank braille = disconnected
        return
    snr = int(sigs) - int(noises)
    sys.stdout.write(col(cell(snr_bars(snr)), FG))


if __name__ == "__main__":
    main()
