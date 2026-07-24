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

- **Rules over suggestions**: When asked to permanently change behavior, enforce it with a mechanical check (pre-commit hook, linter, CI rule) rather than just a CLAUDE.md note. Instructions I can ignore aren't reliable guardrails.
- **Audit the generator, not the symptom**: an observed defect implicates the whole class produced by the same process P (shared assumption, batch, source, tool). On any error — mine or yours catching mine — name P, sweep all of S(P), then patch. Don't fix one item and move on. **Trigger: `frpr`** — re-derive the recent batch of my claims from first principles, prior reasoning suspended; report what survives.
- **Tug the last strand — ground every load-bearing number before concluding**: my self-audit reliably fires on *impossible* outputs (a residual >1, percentages summing >100%) but *fails on plausible ones* — worst when the plausible number confirms a thesis I'm building (e.g. reported `size1` as a 0.43-orthogonal facet without ever looking at its values; they were a sentinel-laden grab-bag). Fix = **grounding as a termination criterion**: a derived number isn't done until it traces to a source of truth I can't decompose (raw column *values*, a measured quantity, a definition). This has a floor (so no infinite regress) and a bar (a derived number is *not* a source of truth, so "stop here" is illegal while the strand is slack). Every added element — facet, column, metric, code — must **resist when pulled** (ablation / look at raw values / find the case that would make it lie); if nothing load-bearing resists, cut it or demote to a legacy marker. Self-detectable tell: **"am I citing a number, or the number's source?"** — if the number, I haven't hit bottom. **Syntactic trigger for *when* to check: "because X, therefore Y"** — the moment a claim becomes a premise, X took weight; draw ONE backward edge to X's immediate support and check it's grounded, regardless of how solid X feels (build the dependency graph lazily/by-leverage, not up front; stop at ground, don't recurse the tree). Gate the intersection of **high-betweenness × ungrounded**, not every concept. See [[feedback_tug_last_strand]].
- **Render rich markdown via Quarto for viewing** (macOS — needs `quarto` + `open`; skip on headless hosts): when sharing or opening markdown with mermaid charts, LaTeX, complex tables, or other rendered content, render it first: copy to `/tmp/`, swap any non-Quarto frontmatter for a Quarto block (`format: html, embed-resources: true, toc: true`), run `quarto render foo.qmd --to html`, then `open foo.html`. Plain `open foo.md` falls through to TextEdit and shows raw source — chart blocks become unrendered text. This applies to memory files (which carry their own `name/description/type` frontmatter), gallery output, any `synthesis_*.md` with embedded diagrams.
- No "created by claude" in commit messages — **except** under `~/Projects/work/`, which has its own policy using `Co-Authored-By: Claude` trailers with `Claude-Model:` + `Claude-Provider:` (bedrock/vertex/foundry/anthropic, auto-detected from `CLAUDE_CODE_USE_*` env). Details live in `~/Projects/work/CLAUDE.md`; global hook has a carve-out for that path.
- Prefer polars over pandas
- **Prefer `mlr` (Miller) over `awk` for CSV one-liners**. awk splits on every delimiter and silently misreads quoted fields containing commas/newlines, which can blank out a file before the failure is visible. `mlr` is CSV-aware: `mlr --csv filter '$id != "1"' f.csv`, `mlr --csv join -j key -f left.csv right.csv`, `mlr --csv cat --from f1.csv --from f2.csv`. Worth the small DSL learning curve; can also convert CSV ↔ TSV ↔ JSON in one step.
- **NEVER use `cd`** - use absolute paths
- **Prefer make/task over scripts** (temp scripts OK in `$TMPDIR`, never bare `/tmp/`)
- **Never put `!` (esp. `!=`) in a heredoc / double-quoted shell string** — zsh history-expands `!` to `\!`, silently corrupting the content (Python then dies with `SyntaxError: unexpected character after line continuation`). Write the script with the Write tool instead of a heredoc, or rephrase (`not (x == y)`). Same trap with `noclobber`: `>` won't overwrite an existing temp file — use a fresh name or `rm` first.
- Background tasks: ring tmux bell (`tput bel`) on complete
- Delete via Trash: `mv <path> ~/.Trash/` (not `rm -rf`); on Linux hosts with no Trash, move to a `/tmp` holding dir or confirm before `rm`
- **Never move/delete working directory** - breaks session
- **Commit raw assets before transforming** — commit clean images/files before applying labels, resizing, etc. so originals are recoverable from git history
- **Dotfiles**: bare repo at `~/.dotfiles`, work tree `$HOME`. Use `git --git-dir=~/.dotfiles --work-tree=~ <cmd> -- <path>`

## Git Rebase Conflict Resolution

When resolving merge conflicts during a rebase, **understand both changesets holistically before touching any conflict**:
1. Read both complete file versions (`git show base:file` and `git show branch:file`)
2. Understand the semantic intent of each side's changes as a whole
3. Design the merged result — anticipate signature changes, duplicate definitions, downstream effects
4. Resolve all conflicts in one coherent pass

Never resolve conflicts piecemeal — that leads to discovering problems after the fact (duplicate functions, arity mismatches, etc.).

## Commit Chunking

When committing accumulated changes that span multiple features or sessions:
1. **Map the dependency DAG** — identify which changes depend on which (e.g., new module → exports in `__init__.py` → CLI flags that use it)
2. **Commit in topological order** — dependencies before dependents, so every commit builds/imports cleanly
3. **One topic per commit** — infrastructure, then features, then data; not by session or by file
4. If files have interleaved changes from multiple topics, commit the foundational layer first

## Signal Pipeline Auditing

When investigating an existing signal/feature column whose generating code may be unavailable:
1. **Decompose empirically** — correlate against its inputs and the target outcome
2. **Grep for consumers** — read how downstream code uses it; column name + decomposition can mislead about intent

Both steps required; either alone produces unverified claims about the pipeline.

When a signal shows fold-by-fold instability, distinguish **detection broke** (structure/coverage degraded → tune resolution/threshold) from **calibration broke** (input→output mapping flipped → rolling window or regime-conditional mapping). Different lever for each — misattribution wastes the next iteration.

When testing whether metric X carries information beyond mechanism Y, the noise null must **preserve Y while breaking only the structure X claims to detect**. A null that destroys both makes the test trivially significant in either direction. Example: testing whether persistent homology cycle counts measure "topology" — a column-shuffle null destroys clustering AND topology, so any clustered-vs-shuffled comparison just measures clustering. The right null preserves clustering (e.g., within-cluster shuffle) and tests only the residual claim.

## Debrief Pattern

On "debrief" or major phase completion, provide:
- **Surprised**: Unexpected findings
- **Not surprised**: Expected outcomes
- **Dead ends**: What didn't work and why
- **Pushback**: Where the user's workflow or instructions violated best practices this session. Be specific and honest — name the practice being violated, the concrete instance, and the consequence. Examples: evaluating on training data, accumulating uncommitted work, optimizing one task without measuring aggregate impact, ephemeral code for reproducible pipelines. This section exists because the default is to not push back.
- **Worth saving?**: Insights to graduate to CLAUDE.md or memory
- **Next**: What happens next
- **Doc check**: Is the project CLAUDE.md (especially Current Frontier) still accurate? Flag if stale.

Format: 2-3 bullets per section.

## Bearing Check

The directional sibling of "debrief". A debrief is retrospective (what happened);
a bearing check is **course-relative** — does the accumulated evidence still point
at the destination, and what's pushing toward or away from it. On "bearing check":

- **Heading**: one line restating the trajectory/destination, so the rest has something concrete to measure against
- **Tailwinds**: findings/decisions pushing toward the heading
- **Headwinds**: findings undermining or complicating it
- **Net bearing**: on course / drifting / off-course + the single biggest strategic risk
- **Course correction**: the highest-leverage next move

Rule that keeps it useful: winds are scored *relative to the stated heading* (a
finding isn't good or bad in the abstract — it's a tail/headwind given where you're
going), and **the Tailwinds list gets no padding**. The moment it reads as
everything-is-going-great, it's worthless.

## Load-Bearing Pass

Validate long-form prose (blog posts, reports, docs) by checking a compact **skeleton**, not by re-reading the draft — re-reads burn tokens and still miss stale claims. Two invariants:

- **Grounded (vertical, ⊨)**: every quantitative/factual claim traces to a source of truth — a results file, a measured number, a prior result. Build a **claim ledger** (`claim → source → value`); hunt orphan numbers (a figure with no live source).
- **Builds (horizontal, ⊢)**: every paragraph is load-bearing on the previous — it follows from it or advances it. Build a **paragraph spine** (one line each); delete-test for filler, check line *n* connects to *n−1* for flow gaps.

When a number changes, patch the ledger and every dependent claim is visible at once — don't re-scan prose hoping to spot the stale one. Regenerate prose *from* a validated spine rather than editing in place. **Trigger: "load-bearing pass"** (or "lbp"). Origin: a stale "movie is a wall" claim survived three re-read passes on a blog draft until the user caught it.

## Three-Layer Documentation

Maintain three layers of project context. Each serves a different audience (scope):

1. **Ecosystem map** (`~/Projects/CLAUDE.md`) — cross-project dependency graph. Update when projects are created, archived, or change relationships.
2. **Project CLAUDE.md** — architecture, current frontier, known issues. Update when capabilities land or priorities shift. Cross-reference upstream/downstream.
3. **Memory files** — experimental history, findings, gotchas. Update during/after sessions. Mark ephemeral artifacts (tmp scripts) as historical.

When any layer changes, check if the others need updating too.

## Tmux Task Trace

A live side panel showing a series of actions taken during a session.

On user request ("show trace", "track progress", "task trace", etc.):
1. **Choose a short project name** based on what we're working on (e.g., `dyf`, `supabase-audit`, `blog`)
2. Write to `/tmp/tasktrace_<project>.md` (keep lines <45 chars)
3. Open split and name the pane:
   ```
   tmux split-window -h -l 50 "nvim -R -c 'set autoread norelativenumber nonumber noruler noshowcmd noshowmode laststatus=0 signcolumn=no | hi Normal guibg=NONE ctermbg=NONE | call timer_start(1000, {-> execute(\"checktime\")}, {\"repeat\": -1})' /tmp/tasktrace_<project>.md"
   tmux select-pane -T "trace:<project>"
   ```
4. Update file as actions complete; notify: `tmux display-message "Task trace updated"`

**Format**: chronological list of actions with status
```
# Project Name — Task Trace

## Actions
- [x] Ported embedding_metrics into train.py
- [x] Copied catalog_lookup.py + CSV
- [x] Refactored train.py for variants
- [x] Fixed stale BATCH_ID in .envrc
- [ ] Run multi-variant training
- [ ] Fix broken test_label_format.py

## Decisions
- vespa.toml is sole BATCH_ID source
- Config gate: [training.pretrained]

## Blocked
- (none)
```

- Multiple sessions safe: each gets a unique project name, no file collisions
- If project scope changes, pick a new name and reopen the split
- **On shutdown**: append Debrief to trace file, then close the pane: `tmux list-panes -a -F '#{pane_id} #{pane_title}' | grep "trace:<project>" | cut -d' ' -f1 | xargs -I{} tmux kill-pane -t {}`
- Traces accumulate as `/tmp/tasktrace_*.md` for periodic theme review

## Tmux Pane Labels (multi-session disambiguation)

`~/.claude/popups/update_labels.sh` computes per-pane status labels from `pane_title` + cwd. When multiple Claude sessions share a cwd basename, they all collapse to one label. Two features:

- **Path-deepening fallback**: generic titles fall back to `parent/dirbase` (so `~/Projects/work/curvo/dex` shows as `curvo/dex`, not bare `dex`). Falls back to bare basename when parent is `$HOME` or `/`.
- **Override**: write `~/.claude/popups/labels/<pid>.override` to pin a label. Survives the Claude spinner's `pane_title` race that defeats `tmux select-pane -T`.

```bash
echo 'workstream-name' > ~/.claude/popups/labels/$(tmux display-message -p '#{pane_pid}').override
```

Cleanup loop removes `<pid>` and `<pid>.override` when the pane dies. Set early in a session when running parallel Claude panes; bare `tmux select-pane -T` won't stick.

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

Per-thread resume files at `<project>/.resume/<thread>.md` — gitignored, never committed. Thread = short work-area identifier ("mercy", "engineering-sweep", "kpmg-sample"). Declare the thread on start; ask the user if unclear.

**Start**: list `<project>/.resume/`, read your thread's file, acknowledge, delete it. Also consume any legacy `## 🔄 RESUME CONTEXT - DELETE AFTER READING` blocks in project CLAUDE.md the same way. Resume blocks are one-shot — the next session on the same thread reads and deletes.

**End** ("shutdown", "update resume context"): promote durable content to memory FIRST, then write `.resume/<thread>.md` covering Current Status, What Was Built, Blocked On, Next Actions, Context to Remember. Template: `~/.claude/resume_template.md`. Keep it under ~500 lines — longer means content should have been promoted to memory. Stale orphan files (>2 weeks, no obvious owner) → promote anything useful to memory and trash.

**Parallel sessions**: write only to your own thread's file. Never modify another thread's resume — including the global rule that you don't alter resume context belonging to another session.

**First-time setup in a project**: `mkdir <project>/.resume/` and add `.resume/` to that project's `.gitignore`.

**For users**: type "update resume context" before ending; optionally "update resume context for <thread>".

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

---

## 🦴 Local model offload (DS4)

`./ds4-server` exposes OpenAI/Anthropic APIs at `127.0.0.1:8000`. Slow (~16 t/s gen) but 1M ctx + on-disk KV cache. Reach for it when:

- **Repo archaeology** — feed source, ask "where is X / what was the design" on dyf, shortorder, owlbear, cochlear after a break
- **Long ML log triage** — inspectable-experiment outputs; grounded pointers to events
- **`sec10quant` 10-Q summarization** — long filings, reading-heavy, privacy-bounded
- **Cloud-API-off-limits material** — internal/NDA/personal; privacy moat changes the option set
- **Overnight batch jobs** — tag, summarize, extract from corpora; 16 t/s is fine at 3am

**Avoid**: code generation, SQL, schemas, math — anywhere precise output beats grounded reading.

**Setup**: needs `iogpu.wired_limit_mb=92000` (LaunchDaemon installed); GGUF on `/Volumes/Models`.

---

## 🪪 Accounts & Handles

- **Hugging Face**: user `jdonaldson` (org `Hushh`). Spaces/models → `huggingface.co/{spaces,}/jdonaldson/<name>`. Needs a **write**-scoped token for repo/space creation (`hf auth login`).
- **GitHub**: `jdonaldson`.
