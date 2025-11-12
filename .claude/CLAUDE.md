⚠️ **SECURITY NOTICE**: This file is private and located in `~/.claude/`. However, project-specific CLAUDE.md files (e.g., `~/Projects/*/CLAUDE.md`) ARE committed to GitHub repositories. Never put sensitive information (credentials, API keys, customer data, internal system details) in project CLAUDE.md files.

---

- don't add created by claude to the commit messages
- prefer to use polars where possible.
- when running long tasks in background, automatically set up a monitoring script that rings the tmux bell (using `tput bel`) when complete
- **Terminal**: Using Kitty terminal with image display support
  - For plots/visualizations: Use `chafa --format symbols --symbols block --size 100x30 <file> && tput sgr0` to display inline
  - **IMPORTANT**: Always run `tput sgr0` after chafa to reset terminal colors
  - Alternative: Generate plots and user views with `kitty +kitten icat <file>` or `open <file>` manually (user runs these)
  - **CLI sparklines**: For quick data viz in bash output (which shows only 3 lines), use compact sparklines:
    ```python
    # Line 1: Header with key values
    # Line 2: Unicode sparkline (█▇▆▅▄▃▂▁ blocks)
    # Line 3: Summary stats (range, mean, total)
    ```
    - Install plotext for ASCII plots: `pip install plotext`
    - For bash-friendly output, prefer simple Unicode bars over plotext (ANSI codes clutter bash output)
    - Example: `print("Data: val1, val2, val3\n█▃▁\nRange: X-Y")`

## Debrief Pattern
Use for task completions, analysis phases, major work milestones:
- **Surprised**: Unexpected findings
- **Not surprised**: Expected outcomes
- **Next**: What happens next

**Usage:**
1. User types "debrief" → Provide structured reflection (2-3 bullets per section)
2. Major phase completion → Update tmux title with debrief format

**Examples:**
```
# Command response:
Surprised: .bin files corrupted, .vec worked perfectly
Not surprised: 113K samples trained well with pretrained vectors
Next: Monitor completes, evaluate model predictions

# Tmux title:
UOM: 86K products | Surprised: CA→CS 4.1M | Not: Variance common | Next: Report
```

## Tmux Configuration

### Window Names
- Set window name to `claude:<project>-<task>` on session start
- Extract project name from working directory (e.g., "krapivin", "curvo", "bamf_docs")
- Add task suffix to distinguish multiple sessions in same project (e.g., "-uom", "-duplicates", "-buckets")
- Command: `tmux rename-window "claude:<project>-<task>"`
- Helps distinguish between multiple concurrent Claude sessions
- **Important**: When multiple Claude sessions work on the same project, each needs a unique task identifier to avoid confusion

### Pane Titles
- Set when starting major work: `Task: metrics | Context: XK/200K (X%)`
- Update at 25%, 50%, 75% context thresholds
- On completion: Use debrief format (see above)
- Command: `tmux select-pane -T "Your Title"`

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
