# CLAUDE_RATIONALE.md

Rationale and context behind decisions in CLAUDE.md. Each entry links to a terse decision with the full story.

---

## 2025-01-06: File organization for retention

**Decision**: Add meta-instructions at top of CLAUDE.md about how to organize and read the file itself.

**Context**: Discussion about how Claude's attention works - "lost in the middle" phenomenon where middle of context gets less attention than beginning and end.

**Rationale**: If the file tells Claude how to read it (prioritize first section, scan headers, re-check critical rules), this compensates for uneven attention. Self-organizing instructions that make the file more effective at its own purpose.

---

## 2025-01-06: Insight Capture Pattern with decision/rationale split

**Decision**: Keep CLAUDE.md terse (decisions only), store rationale in sibling CLAUDE_RATIONALE.md files.

**Context**: Discussion about how to maintain continuity when working with Claude across sessions. The challenge: Claude starts fresh each time, so the user has to maintain context. Writing things down helps, but CLAUDE.md files were getting cluttered with explanations.

**Rationale**: Separating "what" from "why" keeps the main file scannable while preserving reasoning for when decisions need revisiting. The decision is what matters for day-to-day work; the rationale matters when questioning or updating past choices.

---

## Critical Rules - Details & Examples

### Never use `cd` in bash commands
**Rationale**: Changing directories causes confusion and makes it hard to track working directory state.

**Examples**:
- ❌ Bad: `cd exploration && quarto render file.qmd`
- ✅ Good: `quarto render /Users/jdonaldson/Projects/vespa/exploration/file.qmd`

### Prefer make/task over scripts
**Rationale**: Make targets are documented, repeatable, version-controlled, and discoverable.

**Examples**:
- ✅ Good: `make train`, `make deploy`, `make test`
- ⚠️ Acceptable: Temporary scratch scripts in `/tmp/` for exploration
- ❌ Bad: Creating scripts for training/deploying/testing instead of make targets

**Rule**: If a script is part of training, deploying, testing, building, or any repeatable workflow, it MUST be in a make/task command. Exception: Temporary exploration scripts in `/tmp/` are OK, but move to make if reused.

### Delete via Trash
**Rationale**: Allows recovery if something important was accidentally deleted.

**Command**: `mv <path> ~/.Trash/`

### Prefer polars over pandas
**Rationale**: [TBD - likely performance/memory on large datasets]

---

## Debrief Pattern - Examples

```
# Command response format:
Surprised: .bin files corrupted, .vec worked perfectly
Not surprised: 113K samples trained well with pretrained vectors
Next: Monitor completes, evaluate model predictions

# Tmux title format:
UOM: 86K products | Surprised: CA→CS 4.1M | Not: Variance common | Next: Report
```

