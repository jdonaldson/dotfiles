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

## 2026-04-28: Signal Pipeline Auditing pattern

**Decision**: When investigating a derived signal, do BOTH empirical decomposition AND grep for consumers. When a signal is fold-unstable, distinguish detection-broke from calibration-broke before redesigning.

**Context**: sec10quant arc applying dyf's diagnostic stack to SEC 10-Q text signals. The `composite_score` column in `prototype_signals.parquet` had Q5−Q1 spread of −2.67%/qtr across 9 walk-forward years (2017-2025). I declared "the strategy uses it directionally, so this is a bug" without ever reading sec10quant's strategy/portfolio code — that attribution was unverified. The grep for `composite_score` returned only an unrelated archive script with a different formula; I should have searched broader (`composite`, portfolio generation, trade signal logic) before claiming what the strategy *does* with it.

Separately, when 2022 was the weakest PH-cycle year (β=+0.31 vs +0.74 to +1.74 elsewhere), the H1-H5 stress test cleanly distinguished topology coverage (unchanged at 55.8%, detection intact) from cycle-direction calibration (51.7% flip rate vs 14-19% in neighbor years, calibration broken). The fixes for these two failure modes are entirely different — resolution/threshold tuning for detection failures, rolling-window or regime-conditional mapping for calibration failures. Misdiagnosing detection-broke as calibration-broke (or vice versa) sends the next experiment in the wrong direction.

**Rationale**: Code-deletion erodes signal documentation faster than column names rot, so empirical decomposition is necessary but not sufficient — strategy code is where intent lives. Signal failures cluster into two modes that share symptoms (low spread, low t-stat) but require opposite remedies. Both lessons came from concrete misses in this arc, not abstract principle.

---

## 2026-04-29: Null-design rule — preserve Y while breaking X only

**Decision**: When testing whether metric X carries information beyond mechanism Y, the noise null must preserve Y while breaking only the structure X claims to detect.

**Context**: Persistent homology layer of the dyf diagnostic stack claimed PH cycle counts measure topology in biological data. First-pass falsification used column-wise PCA shuffle as the null (preserves marginals per PC, destroys all joint structure). Found real cycle counts systematically below shuffled-noise across 18 (tissue × landmark) configs at z = −5 average. Looked devastating. But column-shuffle destroys *both* clustering and topology — and clustered data necessarily has fewer ripser cycles than isotropic spread data, regardless of within-cluster topology, so the test reduced to "is the data clustered?" (yes, trivially). The within-cluster-shuffle null (preserves cell-type clusters, breaks within-cluster joint structure) was the right test for "does PH detect topology beyond clustering?" Under that null, real ≈ shuffled in count → count claim falsified. But vertex-content entropy and pooled cell-cycle ring detection survived.

**Rationale**: The general pattern: any "does X add information beyond Y" test needs a null that's matched on Y. Otherwise the test answers "does X correlate with Y?" rather than the intended "does X add to Y?" — different question, often trivially true. This compounds with the broader auditing pattern (decompose empirically + grep for consumers + distinguish detection-vs-calibration failure modes): the null choice is upstream of all of them. A wrong null produces a wrong answer that subsequent decomposition won't catch.

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

