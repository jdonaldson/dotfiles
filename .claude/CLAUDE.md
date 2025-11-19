⚠️ **SECURITY NOTICE**: This file is private and located in `~/.claude/`. However, project-specific CLAUDE.md files (e.g., `~/Projects/*/CLAUDE.md`) ARE committed to GitHub repositories. Never put sensitive information (credentials, API keys, customer data, internal system details) in project CLAUDE.md files.

---

- don't add created by claude to the commit messages
- prefer to use polars where possible.
- **NEVER use `cd` to change directories in Bash commands** - always use absolute paths instead
  - ❌ Bad: `cd exploration && quarto render file.qmd`
  - ✅ Good: `quarto render /Users/jdonaldson/Projects/vespa/exploration/file.qmd`
  - Reason: Changing directories causes confusion and makes it hard to track working directory state
- **STRONGLY prefer make/task commands over scratch scripts**
  - ✅ Good: `make train`, `make deploy`, `make test`
  - ⚠️ Acceptable: Temporary scratch scripts in `/tmp/` for exploration or one-off analysis
  - ❌ Bad: Creating scripts for training/deploying/testing instead of using make targets
  - **Rule**: If a script is part of training, deploying, testing, building, or any repeatable workflow, it MUST be in a make/task command
  - **Why**: Make targets are documented, repeatable, version-controlled, and discoverable
  - **Exception**: Temporary exploration scripts in `/tmp/` are OK for analysis, but move to make if reused
- when running long tasks in background, automatically set up a monitoring script that rings the tmux bell (using `tput bel`) when complete
- **Report Visualizations**: When generating reports (Quarto, markdown, etc.), proactively propose and create visualizations using existing data
  - Use Python code chunks in Quarto reports with matplotlib/seaborn for static visualizations
  - Embed visualizations directly in self-contained HTML reports
  - **Always create histograms and timeline plots when relevant**:
    - Histograms: For distributions of numerical data (deal values, counts, prices, scores)
    - Timeline plots: For any date-based data (acquisitions over time, transactions, events)
    - Combination plots: Histograms with timelines (e.g., bar chart + line overlay)
  - Other common visualizations: bar charts for top categories, scatter plots for correlations, heatmaps for confusion matrices
- **Quarto Reports**: Always let Quarto handle section numbering automatically
  - Set `number-sections: true` in YAML frontmatter
  - NEVER manually number headers (e.g., use `## Title` not `## 2. Title`)
  - Quarto will automatically number all sections based on hierarchy
  - **Figure sizing**: Set `fig-width: 8` and `fig-height: 5` (or smaller) to prevent horizontal scrolling
  - Add CSS to constrain images: `img, figure { max-width: 100%; height: auto; }`
  - Always enable `fig-responsive: true` in YAML frontmatter
- **Markdown Bullet Points**: ALWAYS add a blank line before starting a bullet list
  - ❌ Bad: `**Key Points**:\n- Item 1\n- Item 2`
  - ✅ Good: `**Key Points**:\n\n- Item 1\n- Item 2`
  - Reason: Proper markdown rendering requires blank line separation between text and lists
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

## Quarto Report Rendering Tips

**Quick Commands**:
- **Render to HTML**: `quarto render <file>.qmd`
- **Single-file output**: Set `embed-resources: true` in YAML frontmatter
- **Live CSS editing**: Set `embed-resources: false` and link external CSS file
- **Switch back to single file**: Change `embed-resources: false` → `true` and re-render

**Common Rendering Issues**:
- **Bullet points not rendering**: Add blank line before all lists (bulleted and numbered)
- **Horizontal scrolling**: Check figure sizes (use `fig-width: 8`, `fig-height: 5` or smaller)
- **CSS not updating**: If using external CSS, make sure `embed-resources: false`
- **Single file vs. multiple files**:
  - `embed-resources: true` - Single HTML file with all assets embedded (best for sharing)
  - `embed-resources: false` - Separate CSS/image files (best for iterative styling)

**Best Practices**:
- Default to `embed-resources: true` for final deliverables
- Use `embed-resources: false` only when actively editing CSS
- Always test bullet point rendering after adding new lists
- Figure size of 8x5 inches works well for most visualizations
- All 10 code cells should execute successfully before final render

## Workflow DAG Visualization Pattern

**Pattern for complex workflow documentation:**

When documenting complex workflows with multiple interconnected components (like Make targets, CI/CD pipelines, data pipelines):

1. **Create separate DAG.qmd file** (not embedded in CLAUDE.md)
   - Keeps CLAUDE.md clean and readable as plain markdown
   - Allows Mermaid diagrams to render properly in Quarto
   - Easy to update and maintain separately

2. **Structure DAG.qmd with progressive disclosure:**
   - Overview section explaining the document structure
   - One section per workflow component with:
     - Description of what the component does
     - Small, focused Mermaid diagram showing just that component
     - List of key targets/steps with brief explanations
     - Color-coded nodes by workflow type
   - Final section showing cross-component dependencies at high level
   - Quick reference section with common commands

3. **Reference from CLAUDE.md:**
   ```markdown
   ## Workflow DAG

   Complete visualization of the pipeline showing all targets and dependencies.

   **View the interactive diagram:**
   ```bash
   quarto render DAG.qmd && open _site/DAG.html
   ```

   **Diagram source:** See `DAG.qmd` for the Mermaid source.
   ```

4. **Add to Quarto website navigation** (_quarto.yml):
   ```yaml
   website:
     navbar:
       left:
         - text: "Workflow DAG"
           href: DAG.qmd
   ```

**Benefits:**
- Each workflow component is introduced independently before showing connections
- Easier to understand than one giant monolithic diagram
- Mermaid diagrams render properly in Quarto
- CLAUDE.md stays clean and readable
- Color coding helps distinguish workflow types
- Table of contents allows jumping to specific components

**Example:** See `/Users/jdonaldson/Projects/vespa/DAG.qmd` for reference implementation

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
