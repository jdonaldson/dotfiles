⚠️ Private file (`~/.claude/`). Never put secrets in project-level CLAUDE.md files (committed to git).

---

## 🧠 File Organization for Retention

**When editing this file**:
- **Critical behavioral rules** → immediately below this section
- **Patterns/workflows** → middle sections (use clear headers)
- **Reference/templates** → end of file
- Place new content by priority, not chronologically
- Keep bullets terse; move explanations to CLAUDE_RATIONALE.md
- Periodically consolidate: merge related items, remove obsolete ones, promote important middle items upward

**Target length**: If this file exceeds ~150 lines of actual content, consolidate or split.

---

## Critical Rules

- No "created by claude" in commit messages
- Prefer polars over pandas
- **NEVER use `cd`** - use absolute paths
- **Prefer make/task over scripts** (temp scripts OK in `/tmp/`)
- Background tasks: ring tmux bell (`tput bel`) on complete
- Delete via Trash: `mv <path> ~/.Trash/` (not `rm -rf`)
- **Never move/delete working directory** - breaks session

## Git Rebase Conflict Resolution

When resolving merge conflicts during a rebase, **understand both changesets holistically before touching any conflict**:
1. Read both complete file versions (`git show base:file` and `git show branch:file`)
2. Understand the semantic intent of each side's changes as a whole
3. Design the merged result — anticipate signature changes, duplicate definitions, downstream effects
4. Resolve all conflicts in one coherent pass

Never resolve conflicts piecemeal — that leads to discovering problems after the fact (duplicate functions, arity mismatches, etc.).

## Debrief Pattern

On "debrief" or major phase completion, provide:
- **Surprised**: Unexpected findings
- **Not surprised**: Expected outcomes
- **Dead ends**: What didn't work and why
- **Worth saving?**: Insights to graduate to CLAUDE.md or memory
- **Next**: What happens next

Format: 2-3 bullets per section.

## Tmux Topic Trace

On user request ("show trace", "track progress", etc.):
1. **Choose a short project name** based on what we're working on (e.g., `dyf`, `supabase-audit`, `blog`)
2. Write to `/tmp/learnings_<project>.md` (keep lines <45 chars)
3. Open split: `tmux split-window -h -l 50 "nvim -R -c 'set autoread norelativenumber nonumber noruler noshowcmd noshowmode laststatus=0 signcolumn=no | hi Normal guibg=NONE ctermbg=NONE | call timer_start(1000, {-> execute(\"checktime\")}, {\"repeat\": -1})' /tmp/learnings_<project>.md"`
4. Update file as conversation progresses; notify: `tmux display-message "Trace updated"`

- Multiple sessions safe: each gets a unique project name, no file collisions
- If project scope changes, pick a new name and reopen the split
- **On shutdown**: append Debrief (Surprised/Not surprised/Next/Dead ends/Worth saving?) to trace file, then close the pane with `tmux list-panes -F '#{pane_id} #{pane_start_command}' | grep learnings_<project> | cut -d' ' -f1 | xargs -I{} tmux kill-pane -t {}`
- Traces accumulate as `/tmp/learnings_*.md` for periodic theme review

Sections: Flow, Deferred, Decisions, Files Modified, Git, Blockers, Background Tasks, Scratchpad, Debrief (appended on shutdown)

## Concept Graph (Pre-Edit Lookup)

Before editing CLAUDE.md sections, memory files, or learnings patterns, check what else needs updating:

1. `dyf concepts check` — if STALE, run `dyf concepts build` first
2. `dyf concepts query "<section name>"` — 3ms header match, returns neighbors
3. Read all neighbors. Update the **definition first**, then consumers.

- Falls back to `--semantic "query"` for free-text (~4s, needs MiniLM)
- Rebuild: `dyf concepts build` (re-embeds all config + memory + learnings)
- Config: `~/.config/dyf/concept_graph.json` (optional) | Graph: `~/.dyf/concept_graph.json`

---

## 🔄 Session Continuity

On session start: check for `## 🔄 RESUME CONTEXT - DELETE AFTER READING` in project CLAUDE.md. Read it, delete it, acknowledge, and continue.

On session end ("shutdown", "update resume context"): write the resume section with Current Status, What Was Built, Blocked On, Next Actions, Context to Remember. Template: `~/.claude/resume_template.md`

**For users**: type "update resume context" before ending a session.

---

## 📋 Project Recap

**Triggers**: "recap", "what's the status", "catch me up", or proactively if last commit >7 days old.

1. Check: `git log --oneline -15`, `git diff --stat main...HEAD`, file mod times
2. Summarize: recent changes, current state, key context, open threads

Keep it brief: 5-10 bullets max.

---

## 💡 Insight Capture

When significant insights emerge:
1. Offer to save: "Worth saving?"
2. **CLAUDE.md** → terse conclusion; **CLAUDE_RATIONALE.md** → full context, dated
3. Root level = cross-project; project level = domain-specific

**Triggers**: "save this insight", "add this to CLAUDE.md" — or proactively suggest.

**Skip**: Task status (use Resume Context), temporary details, sensitive info.
