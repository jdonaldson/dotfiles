# Claude Code Instructions

Global instructions for Claude Code. Edit to customize Claude's behavior.

---

## Critical Rules

<!-- Add your non-negotiable rules here -->
- Delete via Trash: `mv <path> ~/.Trash/` (not `rm -rf`)
- Use absolute paths (avoid `cd`)

---

## Preferences

<!-- Add your preferences here -->
<!-- Examples:
- Prefer X library over Y
- Always run tests after changes
- Use specific coding style
-->

---

## Patterns

<!-- Define reusable patterns Claude should follow -->

### Debrief Pattern

On "debrief" or major phase completion, provide:
- **Surprised**: Unexpected findings
- **Not surprised**: Expected outcomes
- **Next**: What happens next

---

## Project-Specific

For project-specific instructions, create a `CLAUDE.md` in the project root.

⚠️ **Security**: Project CLAUDE.md files may be committed to git. Never include credentials, API keys, or sensitive information.
