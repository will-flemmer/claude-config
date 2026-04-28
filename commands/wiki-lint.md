---
description: Health-check the LLM wiki for structural and content issues
argument-hint: [--fix]
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, mcp__qmd__query
model: claude-opus-4-7
---

# wiki-lint

**EXECUTION**: Main Claude agent (no routing)
**PURPOSE**: Health-check the LLM wiki for structural and content issues

**WIKI_ROOT**: ~/Documents/llm-wiki

---

## 🚨 MANDATORY SKILL INVOCATIONS - DO THESE FIRST 🚨

**BEFORE doing ANYTHING else, invoke these skills:**

1. **About to read/search 2+ files?**
   ```
   Skill({ skill: "parallel-execution-patterns" })
   ```
   ↳ Executes reads/searches in parallel (5-8x faster)

**⚠️ STOP - Did you invoke the skills above? If not, DO IT NOW before continuing!**

---

## What This Does

Runs a comprehensive health check on the wiki, reporting:
- Structural issues (dead links, orphan pages, missing frontmatter)
- Content issues (stale pages, missing backlinks, expandable stubs)
- Consistency issues (index drift, tag inconsistencies, contradictions)

Optionally auto-fixes what it can.

## Usage

```bash
wiki-lint           # Report only
wiki-lint --fix     # Report and auto-fix what's possible
```

## Workflow

### Phase 1: Inventory (Parallel)

Execute in a single message:

1. **List all wiki pages**: `Glob({ pattern: "wiki/*.md", path: "WIKI_ROOT" })`
2. **Read index.md**: `Read({ file_path: "WIKI_ROOT/index.md" })`
3. **Read recent log**: `Bash({ command: "tail -50 WIKI_ROOT/log.md" })`
4. **Get stats**: `Bash({ command: "WIKI_ROOT/tools/stats.sh" })`

### Phase 2: Structural Checks (Parallel)

Run these checks simultaneously:

**2a. Orphan Check**
- Find wiki pages not referenced in `index.md`
- Find wiki pages not linked from any other wiki page
- Severity: Warning

**2b. Dead Link Check**
- Grep all markdown links `[...](...)` across wiki pages
- Verify each target file exists
- Severity: Error

**2c. Frontmatter Validation**
- Every wiki page must have: type, title, created, updated, tags, status, domain
- Check that `type` is one of: source, entity, concept, analysis, answer
- Check that `status` is one of: active, stub, stale, deprecated
- Check that `domain` is from the allowed list in CLAUDE.md
- Severity: Error for missing required fields, Warning for invalid values

**2d. Naming Convention Check**
- Filenames must be lowercase, hyphen-separated, no special characters
- Source/analysis/answer files must start with `YYYY-MM-DD-`
- Entity/concept files must not start with a date
- Severity: Warning

### Phase 3: Content Checks

**3a. Stale Page Check**
- Pages with `updated` date > 6 months ago
- Severity: Warning

**3b. Missing Backlink Check**
- For each link A → B found in Phase 2b, check if B → A also exists
- Report one-directional links that should be bidirectional
- Severity: Warning

**3c. Stub Audit**
- List all pages with `status: stub`
- For each stub, check if sources exist (in the stub's `sources` frontmatter) that could provide more information
- Severity: Info

**3d. Tag Consistency**
- Collect all tags across all pages
- Identify near-duplicates (e.g., "js"/"javascript", "ts"/"typescript", "k8s"/"kubernetes")
- Suggest tag merges
- Severity: Info

### Phase 4: Index Consistency

- **Pages on disk but not in index.md** — Error
- **Entries in index.md for pages that don't exist** — Error
- **Count mismatches** — Warning (e.g., index says "Sources (5 total)" but there are 6)

### Phase 4b: Review-Lesson Hygiene (if `wiki/review-lessons/` exists)

Lessons in `wiki/review-lessons/` are auto-generated from `/review-feedback` distillation. They need separate hygiene checks because they have additional frontmatter (`scope`, `confidence`, `applied_count`, `dropped_count`, `last_confirmed`) and a Tricorder-style kill-switch lifecycle.

**4b.1 Stale Lesson Check**
- Lessons whose `last_confirmed` is > 90 days ago AND `applied_count` has not increased in that window
- Severity: Warning
- Action (not auto-fix): suggest archiving or re-validating

**4b.2 High-Drop-Rate Check (Tricorder kill switch)**
- For each lesson, compute `drop_ratio = dropped_count / max(applied_count, 1)`
- Flag lessons where `drop_ratio > 0.3` AND `applied_count >= 5`
- Severity: Error — the lesson is producing more noise than signal
- Action: change `status: active` → `status: deprecated`, suggest review

**4b.3 Broken Example Check**
- For each lesson, parse the ✅ and ❌ code blocks
- For typescript/javascript/python blocks, run a syntax-only check (e.g. `node --check`, `python -m py_compile`) on the example
- Skip languages without an available syntax checker
- Severity: Warning — example no longer parses, may be using outdated syntax

**4b.4 Scope Validity Check**
- Each lesson must have a `scope` array of glob patterns
- Verify globs are syntactically valid
- If `scope` is missing or empty → Severity: Error (lesson will never be retrieved)

**4b.5 Confidence Sanity Check**
- `confidence` must be `>= 1` (auto-promoted threshold is 3, but human-promoted from `pending-lessons.md` may be lower)
- `supporting_prs` array length should match `confidence`
- Severity: Warning

**4b.6 Contradiction Detection (lesson-vs-lesson)**
- For lessons with overlapping `scope`, check whether the rules contradict
- Use LLM judgment ("does lesson A's rule conflict with lesson B's rule when both apply?")
- Severity: Warning — flag for human review, don't auto-resolve

### Phase 5: Contradiction Scan (LLM Judgment)

For entities and concepts with 2+ sources:
- Read the pages and look for contradictory claims
- Flag any contradictions for human review
- Severity: Warning

This step requires LLM judgment and may be slow for large wikis. For wikis with 100+ pages, limit to pages updated in the last 30 days.

### Phase 6: Generate Report

Output structured markdown:

```markdown
## Wiki Lint Report — YYYY-MM-DD

### Summary
- Total pages: N
- Errors: N
- Warnings: N
- Info: N

### Errors (must fix)

#### Dead Links (N)
- `wiki/entities/foo.md` → `wiki/concepts/bar.md` (target does not exist)

#### Missing from Index (N)
- `wiki/entities/baz.md` not found in index.md

#### Invalid Frontmatter (N)
- `wiki/sources/2026-01-01-foo.md` missing field: domain

### Warnings (should fix)

#### Orphan Pages (N)
- `wiki/entities/qux.md` — no inbound links

#### Stale Pages (N)
- `wiki/concepts/old-pattern.md` — last updated 2025-08-01

#### Missing Backlinks (N)
- `wiki/entities/react.md` → `wiki/concepts/virtual-dom.md` (no backlink)

#### Contradictions (N)
- `wiki/entities/tool-x.md`: Source A says X, Source B says Y

### Info (nice to fix)

#### Expandable Stubs (N)
- `wiki/entities/svelte.md` — has 2 sources available

#### Tag Suggestions
- Merge "js" → "javascript" (3 pages affected)
```

### Phase 7: Auto-Fix (if --fix)

If `$ARGUMENTS` contains `--fix`:

1. **Add missing pages to index.md** — insert in the correct section
2. **Remove dead index entries** — remove entries for pages that don't exist
3. **Add missing backlinks** — if A links to B, add B → A in B's Relationships section
4. **Fill missing frontmatter** — add required fields with sensible defaults (status: active, domain: inferred from directory or content)
5. **Fix count mismatches** — update totals in index.md headers

After fixing, append to log.md:
```markdown
- **HH:MM** LINT: Auto-fix applied
  - Fixed: N dead index entries, N missing backlinks, N frontmatter issues
  - Remaining: N errors, N warnings
```

**Do NOT auto-fix**: contradictions, stale content, tag merges, naming convention issues. These require human judgment.

### Phase 7b: Review-Lesson Auto-Fix (if --fix and review-lessons exist)

Additional auto-fixes specific to review lessons:

1. **Deprecate high-drop-rate lessons** — set `status: active` → `status: deprecated` for lessons failing 4b.2 (kill switch). Add a `deprecated_at` field and a changelog entry.
2. **Set missing tracking fields** — if `applied_count`, `dropped_count`, or `last_confirmed` is missing, initialize them (`applied_count: 0`, `dropped_count: 0`, `last_confirmed: <created date>`).

**Do NOT auto-fix**: contradictions between lessons, stale lessons (suggest archiving but don't act), broken examples (the rule may still be valid even with a stale example).

## Error Handling

- **Empty wiki**: Report "Wiki is empty. Run /wiki-ingest to add your first source."
- **Missing tools/search.sh**: Skip search-dependent checks, note in report.
- **Very large wiki (500+ pages)**: Skip contradiction scan or limit to recent pages. Note in report.

## Requirements

- Wiki repo must exist at `~/Documents/llm-wiki/`
- `rg` (ripgrep) for searching
- `tools/stats.sh` for overview statistics
