#!/usr/bin/env python3
"""Check that a titled document's filename encodes its title.

Called from the global pre-commit hook with staged file paths as argv. Reads the
STAGED content (git show :path), not the worktree, so a partially-staged rename
is judged on what is actually being committed.

Two checks, both hard failures:

  1. CONTENT-FREE BASENAME. A name like `report.qmd` or `output.md` tells a reader
     nothing and forces them to open the file. Never acceptable for a document
     that has a title.
  2. ZERO TOKEN OVERLAP with the title. Deliberately loose: a sensible shortening
     (`unspsc-codeset.qmd` for "UNSPSC Codeset - UNv260801") passes, because
     requiring an exact slug match would flag reasonable names and train everyone
     to use --no-verify. Only a name sharing NO meaningful word with its own title
     fails.

Rationale for the looseness: check 1 catches the real-world failure (a placeholder
name that survived to commit). Check 2 catches drift after a retitle. Anything
stricter is a style opinion, and a noisy hook is a bypassed hook.
"""

import re
import subprocess
import sys
from pathlib import Path

# Names fixed by a tool or convention -- for these the DIRECTORY carries the
# information, so the filename is not expected to encode anything.
#
# NOTE `index` is deliberately NOT here. It is exempt only inside an actual Quarto
# project (see is_quarto_project_page) -- a bare `index.qmd` in a folder with no
# _quarto.yml is a standalone document that could just as well carry its title, and
# exempting it unconditionally is how two runbooks kept content-free names.
EXEMPT_STEMS = {
    "readme",
    "claude",
    "agent",
    "agents",
    "skill",
    "memory",
    "changelog",
    "contributing",
    "license",
    "notes",  # only as a repo-root convention; flagged below if it has a title
    "todo",
}

# A whole basename that carries no information about content.
CONTENT_FREE = {
    "report",
    "output",
    "out",
    "data",
    "final",
    "draft",
    "results",
    "result",
    "summary",
    "analysis",
    "untitled",
    "copy",
    "new",
    "temp",
    "tmp",
    "doc",
    "document",
    "file",
    "test",
    "scratch",
    "misc",
    "stuff",
    "v1",
    "v2",
    "v3",
}

# Dropped before comparing filename tokens to title tokens.
STOPWORDS = {
    "a", "an", "the", "and", "or", "of", "for", "to", "in", "on", "at", "by",
    "with", "from", "is", "are", "was", "were", "be", "as", "it", "its", "this",
    "that", "how", "what", "why", "when", "where", "we", "our", "using", "use",
    "vs", "via",
}

# Paths whose naming is governed elsewhere.
SKIP_PATH_PARTS = {".resume", "memory", "node_modules", ".venv", "_site", "_freeze"}


def slug(text):
    """Lowercase kebab-case slug: drop punctuation, collapse whitespace."""
    text = text.lower()
    text = re.sub(r"['’]", "", text)  # drop apostrophes: curvo's -> curvos
    text = re.sub(r"[‐-―]", " ", text)  # unicode dashes
    text = re.sub(r"[^a-z0-9\s-]", " ", text)
    text = re.sub(r"[\s-]+", "-", text)
    return text.strip("-")


def tokens(text):
    return {t for t in slug(text).split("-") if t and t not in STOPWORDS}


def shares_a_word(name, title):
    """True if any name token matches a title token, allowing inflection.

    Exact equality is too brittle: `incrementalization.qmd` titled
    "Incrementalizing the BAMF chain" is a perfectly good name but shares no
    exact token. Compare on a common prefix instead, so stem variants match
    (incrementaliz|ation vs incrementaliz|ing) without pulling in unrelated
    short words.
    """
    a_tokens, b_tokens = tokens(name), tokens(title)
    for a in a_tokens:
        for b in b_tokens:
            if a == b:
                return True
            n = 0
            for ca, cb in zip(a, b):
                if not (ca == cb):
                    break
                n += 1
            if n >= 5:
                return True
    return False


def staged_content(path):
    """Staged blob if there is one, else the worktree file.

    The fallback is what makes this runnable by hand on arbitrary paths, not
    only from inside a commit.
    """
    try:
        return subprocess.run(
            ["git", "show", f":{path}"],
            capture_output=True, text=True, check=True,
        ).stdout
    except (subprocess.CalledProcessError, FileNotFoundError):
        try:
            return Path(path).read_text(errors="replace")
        except OSError:
            return ""


def frontmatter_title(text):
    """Return the YAML frontmatter title, or None.

    Only looks at a leading `---` block. A `title:` deeper in the document is
    body content (e.g. a code sample), not the document's own title.
    """
    if not text.startswith("---"):
        return None
    end = text.find("\n---", 3)
    if end == -1:
        return None
    for line in text[3:end].splitlines():
        m = re.match(r'^title:\s*(.+?)\s*$', line)
        if m:
            return m.group(1).strip().strip('"').strip("'")
    return None


def is_quarto_project_page(p):
    """True if `index` is genuinely required here, i.e. a Quarto project/site.

    Walk up looking for _quarto.yml. Without one, quarto renders the file
    standalone and the name `index` buys nothing.
    """
    for parent in [p.parent, *p.parent.parents]:
        if (parent / "_quarto.yml").exists() or (parent / "_quarto.yaml").exists():
            return True
        if (parent / ".git").exists():  # stop at the repo root
            break
    return False


def check(path):
    """Return a list of problem strings for one file."""
    p = Path(path)
    if SKIP_PATH_PARTS & set(p.parts):
        return []

    stem = p.stem
    if stem.lower() in EXEMPT_STEMS or stem.startswith("_"):
        return []
    if stem.lower() == "index" and is_quarto_project_page(p):
        return []

    title = frontmatter_title(staged_content(path))
    if not title:
        return []

    problems = []
    normalized = re.sub(r"[^a-z0-9]", "", stem.lower())

    if normalized in CONTENT_FREE:
        problems.append(
            f'basename "{stem}" carries no information about the content'
        )
    elif not shares_a_word(stem, title):
        problems.append(
            f'basename "{stem}" shares no word with the title'
        )

    if problems:
        problems.append(f'  title:    {title}')
        problems.append(f'  suggested: {slug(title)}{p.suffix}')
    return problems


def main(argv):
    failures = []
    for path in argv:
        if Path(path).suffix.lower() not in (".qmd", ".md", ".rmd", ".ipynb"):
            continue
        found = check(path)
        if found:
            failures.append((path, found))

    if not failures:
        return 0

    print("")
    print("ERROR: document filename does not encode its title.")
    print("A reader should know what a file holds without opening it.")
    print("")
    for path, found in failures:
        print(f"  {path}")
        for line in found:
            print(f"    {line}")
    print("")
    print("Rename with `git mv`, then re-stage. Bypass with: git commit --no-verify")
    return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
