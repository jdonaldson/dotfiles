⚠️ **SECURITY NOTICE**: This file is private and located in `~/.claude/`. However, project-specific CLAUDE.md files (e.g., `~/Projects/*/CLAUDE.md`) ARE committed to GitHub repositories. Never put sensitive information (credentials, API keys, customer data, internal system details) in project CLAUDE.md files.

---

## 🧠 File Organization for Retention

**Claude's attention is uneven**: beginning and end of context are reliable; middle is the danger zone.

**When reading this file**:
- Treat the first section after this (Critical Rules) as highest priority
- Scan headers to build mental map before deep reading
- If file is long, re-check Critical Rules section before acting

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

## Debrief Pattern

On "debrief" or major phase completion, provide:
- **Surprised**: Unexpected findings
- **Not surprised**: Expected outcomes
- **Next**: What happens next

Format: 2-3 bullets per section.

## Tmux Configuration

### Window Names
- Set window name to `claude:<project>-<task>` on session start
- Extract project name from working directory (e.g., "krapivin", "curvo", "bamf_docs")
- Add task suffix to distinguish multiple sessions in same project (e.g., "-uom", "-duplicates", "-buckets")
- Command: `tmux rename-window "claude:<project>-<task>"`
- Helps distinguish between multiple concurrent Claude sessions
- **Important**: When multiple Claude sessions work on the same project, each needs a unique task identifier to avoid confusion

### Topic Trace Split
On user request ("show trace", "track progress", etc.):
1. Use project name from working directory (e.g., `curvo`, `krapivin`)
2. Write to `/tmp/topic_trace_<project>.md` (keep lines <45 chars)
3. Open split with neovim (auto-reloads every 1s):
   ```
   tmux split-window -h -l 50 "nvim -R -c 'set autoread | call timer_start(1000, {-> execute(\"checktime\")}, {\"repeat\": -1})' /tmp/topic_trace_<project>.md"
   ```
4. Update file as conversation progresses (read-only for user)
5. Notify on update: `tmux display-message "Trace updated"`

Sections to include:
- **Flow**: topic progression (indented bullets)
- **Deferred**: branches not pursued (short-term memory)
- **Decisions**: key choices made
- **Files Modified**: touched this session
- **Git**: branch + status (if applicable)
- **Blockers**: waiting on / stuck
- **Background Tasks**: running processes
- **Scratchpad**: temp notes, IDs, values

---

## 🔄 Session Continuity Pattern

### How It Works
Projects can include a "RESUME CONTEXT - DELETE AFTER READING" section in their CLAUDE.md that enables seamless session handoffs.

### Claude's Responsibilities
When starting a new session:
1. Check for `## 🔄 RESUME CONTEXT - DELETE AFTER READING` section in project's CLAUDE.md
2. Read and process the context (understand status, blockers, next actions)
3. **Immediately delete the entire section** after reading
4. Greet the user acknowledging the resumed context
5. Continue from where the previous session left off

When ending a session (user says "shutdown", "update resume context", or similar):
1. Update the `## 🔄 RESUME CONTEXT` section with current state
2. Include: Current Status, What Was Built, Blocked On, Next Actions, Context to Remember
3. Be specific and actionable for your future self

### Template Format
```markdown
## 🔄 RESUME CONTEXT - DELETE AFTER READING

**⚠️ INSTRUCTIONS FOR CLAUDE**:
- Read this section when starting a new session
- Complete any pending tasks listed here
- Delete this entire section after processing
- Continue with the conversation

### Current Status
[What's the current state of work]

### What Was Built
[List of completed work/files created]

### Blocked On
[What's preventing progress or waiting on user]

### Next Action When User Returns
[Specific steps to take when conversation resumes]

### Context to Remember
[Important decisions, preferences, or background]
```

### For Users
Run `task shutdown` (if available) or type "update resume context" to prompt Claude to write this section before ending a session.

---

## 📋 Project Recap Pattern

When starting a session after extended absence (>1 week) or on user request ("recap"):

1. Check recent activity:
   - `git log --oneline -15` for recent commits
   - `git diff --stat main...HEAD` if on feature branch
   - File modification times in key directories

2. Summarize for user:
   - **Recent changes**: What was done (commits, new files)
   - **Current state**: Active branch, uncommitted changes
   - **Key context**: Data sources, batch IDs, model configs
   - **Open threads**: What was in progress or blocked

**Triggers**: "recap", "what's the status", "catch me up", or proactively if last commit >7 days old.

**Keep it brief**: 5-10 bullet points max. User can ask for details.

---

## 💡 Insight Capture Pattern

When significant insights emerge (decisions, surprises, clarified preferences, useful mental models):
1. Offer to save: "Worth saving?"
2. Split content:
   - **CLAUDE.md** → terse decision/conclusion
   - **CLAUDE_RATIONALE.md** → full context, dated
3. Place by scope:
   - Root level: cross-project, working style
   - Project level: domain-specific, architectural

**Triggers**: "save this insight", "add this to CLAUDE.md", "worth remembering" - or proactively suggest.

**Skip**: Task status (use Resume Context), temporary details, sensitive info.
