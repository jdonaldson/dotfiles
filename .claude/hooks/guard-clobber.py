#!/usr/bin/env python3
"""PreToolUse(Bash): deny a plain `>` onto an existing regular file.

noclobber is ON in every shell here (zim's `environment` module: `setopt NO_CLOBBER`), including the
Bash tool's. So `cmd > existing.json` does NOT overwrite: the redirect fails, an `&&` chain stops, and
a `;` chain carries on with the STALE file (`jq ... > tmp; mv tmp settings.json`). The fix is always
the same: `>|` to overwrite on purpose, `>>` to append, or a fresh filename.

Best-effort and deliberately conservative: it only judges LITERAL targets (plus ~, $HOME, ${HOME}).
Anything it cannot resolve is allowed, because the shell's own refusal is loud anyway; this hook
exists to catch the case before a `;` chain acts on stale data. A target the same command `rm`s first
is allowed (the file will be gone by the time the redirect runs).
"""
import json
import os
import re
import sys

try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)
cmd = (data.get("tool_input") or {}).get("command") or ""
cwd = data.get("cwd") or os.getcwd()
if ">" not in cmd:
    sys.exit(0)

# Single-quoted strings are program text (jq, mongosh, awk), not redirects.
scan = re.sub(r"'[^']*'", "''", cmd)

# A clobbering redirect: optional fd digit, then `>` not part of `>>`, `>|`, `>&`, `->`, `=>`, `<>`.
REDIR = re.compile(r"(?<![>&|<=\-])(?:\d)?>(?![>|&])\s*(\"[^\"]*\"|[^\s|&;<>()]+)")


def resolve(tok):
    tok = tok.strip('"')
    home = os.path.expanduser("~")
    tok = re.sub(r"^~(?=/|$)", home, tok)
    tok = tok.replace("${HOME}", home).replace("$HOME", home)
    if "$" in tok or "`" in tok or "*" in tok:
        return None  # unresolvable here; let the shell decide
    return os.path.normpath(os.path.join(cwd, tok))


hits = []
for m in REDIR.finditer(scan):
    raw = m.group(1)
    path = resolve(raw)
    if not path or not os.path.isfile(path):  # devices (/dev/null) and new files are fine
        continue
    before = scan[: m.start()]
    if re.search(r"\brm\b[^;&|]*" + re.escape(raw.strip('"')), before):
        continue
    hits.append(raw)

if hits:
    targets = ", ".join(sorted(set(hits)))
    reason = (
        f"Blocked: `>` onto existing file(s) {targets}. noclobber is ON in this shell (zim environment "
        "module), so the redirect would FAIL and any `;`-chained step would run on stale data. "
        "Use `>|` to overwrite on purpose, `>>` to append, or write to a fresh filename."
    )
    print(json.dumps({"hookSpecificOutput": {"hookEventName": "PreToolUse",
                                             "permissionDecision": "deny",
                                             "permissionDecisionReason": reason}}))
sys.exit(0)
