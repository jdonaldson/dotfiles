#!/usr/bin/env python3
"""Wi-Fi signal/noise indicator for the tmux status bar (braille S|N style).

Reads the signal/noise cache written by wifi_refresh.sh (instant). If the cache is
stale (> REFRESH_S) or missing, kicks off a DETACHED background refresh and renders
the last known value -- the ~8s system_profiler probe never blocks the status tick.

Render: signal glyph + one braille char whose LEFT column = signal strength (0-4)
and RIGHT column = noise quality (quieter = taller), then dim "<signal>/<noise>".
Glyph + braille colored by signal quality. Emits tmux #[fg] escapes; set
WIFI_METER_NOCOLOR=1 for plain output.
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
SIGNAL = ""       # nerd-font signal glyph
GREEN, YEL, ORG, RED, DIM = "#a7c080", "#dbbc7f", "#e69875", "#e67e80", "#4f5b58"
DOT = {"L": [0x40, 0x04, 0x02, 0x01], "R": [0x80, 0x20, 0x10, 0x08]}  # bottom->top


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


def sig_level(rssi):
    return 4 if rssi >= -55 else 3 if rssi >= -65 else 2 if rssi >= -72 else 1 if rssi >= -80 else 0


def sig_color(rssi):
    return [RED, ORG, YEL, GREEN, GREEN][sig_level(rssi)]


def noise_q(noise):
    return 4 if noise <= -95 else 3 if noise <= -90 else 2 if noise <= -85 else 1 if noise <= -80 else 0


def main():
    age, sigs, noises = read_cache()
    maybe_refresh(age)
    if sigs == "NA":
        sys.stdout.write(col(SIGNAL + " ⠀", DIM))  # blank braille = disconnected
        return
    rssi, noise = int(sigs), int(noises)
    bits = sum(DOT["L"][i] for i in range(sig_level(rssi))) + sum(DOT["R"][i] for i in range(noise_q(noise)))
    glyph = col(SIGNAL + " " + chr(0x2800 + bits), sig_color(rssi))
    sys.stdout.write(glyph + col(f" {rssi}/{noise}", DIM))


if __name__ == "__main__":
    main()
