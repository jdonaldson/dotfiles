- don't add created by claude to the commit messages
- prefer to use polars where possible.
- when running long tasks in background, automatically set up a monitoring script that rings the tmux bell (using `tput bel`) when complete

## Tmux Pane Title Management
- Set descriptive tmux pane titles when starting new analyses or major work phases
- Include: project/task name, key metrics (record counts, facility counts, etc.), and context usage
- Format: `Task: key metrics | Context: XK/200K (X%)`
- Update title when context usage crosses 25%, 50%, 75% thresholds
- Command: `tmux select-pane -T "Your Title Here"`
- Example: `UOM Analysis: 61M records, 462 facilities | Context: 100K/200K (50%)`
- When completing major analysis phases, update title to include: what surprised you, what didn't surprise you, and what happens next
- Example: `UOM: 86K products w/ variance (342x more!) | Surprised: CA→CS 4.1M transitions | Next: Comprehensive report`

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
