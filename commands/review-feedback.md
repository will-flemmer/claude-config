---
description: Capture verdicts on AI review findings and distill lessons into the wiki
argument-hint: <pr-url> [--public]
allowed-tools: Read, Write, Edit, Bash(gh:*), Bash(git:*), Bash(jq:*), Bash(mkdir:*), Bash(date:*), Bash(ls:*), Bash(cat:*), Bash(test:*), Bash(echo:*), Bash(find:*), Bash(grep:*), Glob, Grep, mcp__qmd__query
model: claude-opus-4-7
---

# Review Feedback

**PURPOSE**: Mine the PR thread for verdicts on AI findings, capture missed-by-AI signals from human reviewers, and distill recurring patterns into wiki lessons that improve future `/review-pr` runs.

**INPUT**: `$ARGUMENTS` — PR URL.

---

## Architecture

This is the **read-side of the self-improving review loop**. `/review-pr` posts findings to the PR. This command:

1. Mines three sources of signal: AI-finding replies, human comments overlapping AI findings, and human comments with no AI overlap (missed)
2. Appends structured records to an episodic JSONL log
3. Distills recent log entries into wiki lessons when patterns cross confidence thresholds
4. Auto-promotes high-confidence lessons; queues the rest for batch review

---

## Storage Layout

All review-feedback state lives **in the repo**, not in `~/.claude/`. This makes it shareable across machines and visible to teammates.

```
<repo-root>/pr-reviews/
├── sidecars/<pr>.json          # written by /review-pr — finding metadata + applied lessons
├── <YYYY-MM>.jsonl             # append-only feedback log (one per month)
└── pending-lessons.md          # candidate lessons awaiting human approval
```

**Resolve `<repo-root>`** at the start of every phase:

```bash
repo_root=$(git rev-parse --show-toplevel)
mkdir -p "$repo_root/pr-reviews"
```

**Public-repo guard.** Before writing any file in `pr-reviews/`:

```bash
visibility=$(gh repo view --json visibility --jq '.visibility')
```

If `visibility == "PUBLIC"` and `$ARGUMENTS` does NOT contain `--public`, refuse to proceed. Tell the user:
- This repo is public; review feedback (including verbatim human comments) will be committed and visible to anyone
- Re-run with `--public` to acknowledge

If `--public` is passed (or repo is private/internal), proceed.

**Distillation scope: per-repo only.** The JSONL log this command reads from is the current repo's `pr-reviews/`. The wiki at `~/Documents/llm-wiki/wiki/review-lessons/` is the cross-repo accumulator — that's where lessons graduate to. Per-repo signal stays per-repo until it makes the wiki.

---

## Phase 1: Load Context (Parallel)

Run in a single message:

```bash
# PR metadata
gh pr view "$ARGUMENTS" --json number,url,headRefOid,author,baseRefName,headRefName

# All inline review comments (with in_reply_to_id, original_line, position)
gh api "/repos/{owner}/{repo}/pulls/<pr_number>/comments" --paginate

# All issue comments (general PR discussion)
gh api "/repos/{owner}/{repo}/issues/<pr_number>/comments" --paginate

# All review-comment threads with resolution status
gh api graphql -f query='
  query($owner: String!, $repo: String!, $pr: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $pr) {
        reviewThreads(first: 100) {
          nodes {
            isResolved
            comments(first: 50) {
              nodes { id databaseId body author { login ... on Bot { __typename } } }
            }
          }
        }
      }
    }
  }
' -F owner=<owner> -F repo=<repo> -F pr=<pr_number>
```

Extract `<owner>`, `<repo>`, `<pr_number>` from `$ARGUMENTS`.

Then read the sidecar:

```bash
cat "$repo_root/pr-reviews/sidecars/<pr_number>.json"
```

**If sidecar is missing** → tell user `/review-pr` was never run on this PR (or was run with `--no-post`). Offer to capture the human comments anyway as "missed" signals (Phase 4 only). Skip Phase 2.

---

## Phase 2: Classify AI Findings (3 sources)

For each finding in the sidecar, check signals in order:

### Source 1 — Direct replies to the finding's posted comment

A comment is a reply if:
- Its `in_reply_to_id` equals the finding's `posted_comment_id`, OR
- Its body contains the finding's `<!-- review-id: ... -->` marker

**Keyword classify the reply body** (case-insensitive):

| Pattern | Verdict |
|---------|---------|
| `false positive`, `fp`, `wrong`, `not an issue`, `incorrect` | `false-positive` |
| `nit`, `ignore`, `wontfix`, `won't fix`, `not now`, `out of scope` | `dropped` |
| `fixed`, `done`, `addressed`, `good catch`, `thanks`, `tysm` | `kept` |
| `intentional`, `by design`, `on purpose` | `false-positive` |

If reply matches none, fall back to LLM judgment on the reply text.

### Source 2 — Independent human comments overlapping the finding

For each finding `(file, line)`, find human comments where:
- `path == file` AND `abs(comment.line - finding.line) <= 5` (use `original_line` if `line` is null due to outdated diff)
- Author is **not a bot** (`__typename != "Bot"`, login does not end in `[bot]`)
- Author is **not Claude/our agent** (skip if author matches the user posting AI reviews)

For each overlap, classify the human's comment **using LLM judgment**:

- Agrees with our finding (raises same concern) → `kept` (verdict_source: `human-overlap-agree`, weight 2x)
- Pushes back / says it's intentional → `false-positive` (verdict_source: `human-overlap-pushback`)
- Different concern at same location → ignore (don't classify the AI finding from this signal)

### Source 3 — Thread resolution

If the reviewThread containing the finding has `isResolved: true` and no other signal exists → `kept` (verdict_source: `thread-resolved`, weight 1x).

### Source 4 — Interactive prompt for unclassified findings

For findings with NO signal from sources 1–3, prompt the user once (batched):

```
Findings with no PR signal — quick verdict per finding:

[1] auth.ts:42 — Missing null check on user.id
    [k]ept / [d]ropped / [f]alse-positive / [s]kip / [m]issed-context?

[2] ...
```

Accept single-letter answers. `s` skips (no record written). `m` lets user provide free-text "actually the AI missed something here too".

---

## Phase 3: Capture "Missed" Signals (Human Comments with No AI Overlap)

For each human comment that:
- Is on a `(file, line)` not within ±5 of any AI finding
- Is not a reply to an AI finding
- Is not trivia (skip: emoji-only, "lgtm", "👍", "approved", reactions)
- Is from a human (not bot, not the AI's author)

**LLM-classify the comment's category:**

- `bug` — flags a correctness/logic issue
- `security` — flags a security concern
- `performance` — perf concern
- `style` — formatting/naming (low priority — usually skip unless substantive)
- `design` — architecture/API design issue
- `test` — missing or wrong tests
- `question` — clarification request (skip)
- `praise` — positive comment (skip)
- `other`

Skip `question`, `praise`, and bare `style` (linter territory).

These become **the highest-value training signal** — they tell future runs what categories you systematically miss.

---

## Phase 4: Append to JSONL Log

Path: `<repo-root>/pr-reviews/<YYYY-MM>.jsonl` (monthly file, append-only).

```bash
log_file="$repo_root/pr-reviews/$(date +%Y-%m).jsonl"
```

**Two record shapes**:

### Finding-verdict record

```json
{
  "type": "finding",
  "ts": "2026-04-28T15:00:00Z",
  "pr_url": "https://github.com/owner/repo/pull/123",
  "pr_number": 123,
  "review_id": "abc123def456",
  "verdict": "kept",
  "verdict_source": "human-overlap-agree",
  "verdict_weight": 2,
  "severity": "high",
  "title": "Missing null check on user.id",
  "file": "src/auth.ts",
  "line": 42,
  "language": "typescript",
  "reviewer": "alice",
  "human_comment": "yeah this would crash on logged-out users",
  "why": null
}
```

### Missed-by-AI record

```json
{
  "type": "missed",
  "ts": "2026-04-28T15:00:00Z",
  "pr_url": "https://github.com/owner/repo/pull/123",
  "pr_number": 123,
  "category": "performance",
  "severity": "medium",
  "file": "src/render.ts",
  "line": 88,
  "language": "typescript",
  "reviewer": "bob",
  "human_comment": "this allocates inside the hot loop"
}
```

Append one record per line. Never rewrite — this log is immutable history.

Detect language from file extension (`.ts` → typescript, `.py` → python, etc.).

---

## Phase 5: Distill Lessons

Re-read the recent window: last 30 days of JSONL OR last 50 entries, **whichever is larger**. **Scope: this repo only.**

```bash
# Cat last 30 days of monthly files in THIS repo
find "$repo_root/pr-reviews" -maxdepth 1 -name "*.jsonl" -mtime -30 -exec cat {} +
```

Distillation never crosses repos at the JSONL level — patterns only emerge from this repo's signal. Cross-repo accumulation happens at the wiki level, where promoted lessons become globally available.

### Pattern detection

Group records and look for these patterns:

#### Pattern A — Recurring false-positives (suppression rule)

Cluster `verdict == "false-positive"` records by **finding-title similarity** (LLM judgment — group findings that describe the same kind of issue, even if titles differ slightly).

**Trigger**: ≥3 false-positives across **≥2 distinct PRs** in the window.

**Lesson**: "Don't flag X when Y" suppression rule.

#### Pattern B — Confirmed valuable findings (positive rule)

Cluster `verdict == "kept"` (especially `verdict_source: human-overlap-agree`) by title similarity.

**Trigger**: ≥3 kept findings across ≥2 distinct PRs.

**Lesson**: "Always check Z" positive rule (raises severity / makes mandatory in scope).

#### Pattern C — Recurring misses (positive rule)

Cluster `type == "missed"` records by `category` AND content similarity.

**Trigger**: ≥2 missed entries of the same kind across ≥2 distinct PRs.

**Lesson**: "Always check for [missed pattern]" — highest priority lesson type.

#### Pattern D — Contrast pair (scoping rule)

Find pairs where the same finding-type was `kept` in one context and `false-positive` in another (different files, different scopes).

**Trigger**: ≥1 contrast pair across distinct PRs.

**Lesson**: A scope-specific rule — "Flag X in `lib/**` but not in `tests/**`."

### Determine confidence

`confidence = number of distinct PRs supporting the pattern`.

Track **scope**: derive scope-glob from the file paths in the supporting records (longest common path prefix → glob).

### Check for existing lessons

For each candidate lesson, query the wiki to see if it already exists:

```javascript
mcp__qmd__query({
  searches: [
    { type: "lex", query: "<rule keywords / proper nouns>" },
    { type: "vec", query: "<candidate rule in natural language>" }
  ],
  collections: ["wiki"],
  intent: "Check whether a lesson on this topic already exists before promoting a new one"
})
```

If a lesson on the same topic exists in `wiki/review-lessons/`:
- Increment its `confidence` count
- Update `last_confirmed`
- If new evidence contradicts it (e.g., 3 fresh false-positives on a "kept" rule), flag for human review — DO NOT silently flip the rule
- Skip auto-promotion (it's already promoted)

---

## Phase 6: Promote or Queue

### Auto-promote when

- `confidence >= 3` (≥3 distinct PRs)
- AND no existing lesson contradicts it
- AND not a contrast/scoping rule (those always need human review)

**Write to** `~/Documents/llm-wiki/wiki/review-lessons/<slug>.md`:

```markdown
---
type: concept
title: <Rule, one sentence>
created: 2026-04-28
updated: 2026-04-28
tags: [review-lesson, <language>, <category>]
status: active
domain: methodology
scope: ["**/*.ts", "src/**/*.tsx"]
confidence: 4
last_confirmed: 2026-04-28
supporting_prs: ["https://github.com/owner/repo/pull/123", ...]
applied_count: 0
dropped_count: 0
---

# <Rule, one sentence>

## Rule
<One-sentence rule>

## Why
<Reason — lets the LLM generalize to edge cases>

## Examples

✅ Good
```<lang>
<good code>
```

❌ Bad
```<lang>
<bad code>
```

## Scope
Applies to files matching: `**/*.ts`, `src/**/*.tsx`

## Evidence
- PR #123: <one-line summary of supporting evidence>
- PR #156: ...

## Changelog
- 2026-04-28: Created from feedback distillation (confidence: 3)
```

Use the wiki slug convention: lowercase, hyphen-separated, max 60 chars.

After writing, **add to wiki index.md** under a "Review Lessons" section (create the section if missing).

Append to `~/Documents/llm-wiki/log.md`:

```markdown
- **HH:MM** REVIEW-LEARN: Promoted N lessons from /review-feedback
  - Created: wiki/review-lessons/<slug>.md
```

### Update applied-lesson counters (Tricorder telemetry)

Read `applied_lessons` from the sidecar. For each entry:

1. Read the lesson file at `~/Documents/llm-wiki/<lesson_path>`
2. Increment `applied_count` by 1 (the lesson was used in this review)
3. For each `review_id` in `influenced_findings`, look up its verdict from Phase 2:
   - If `verdict == "false-positive"` or `verdict == "dropped"` → increment `dropped_count` by 1
   - If `verdict == "kept"` → no change (the lesson did its job)
4. Update `last_confirmed` to today if any influenced finding was `kept`
5. Write the updated lesson back

These counters drive the Tricorder kill switch in `wiki-lint` (auto-disables lessons with `drop_ratio > 0.3` after `applied_count >= 5`).

### Queue when

- `confidence < 3`
- OR is a contrast/scoping rule
- OR contradicts an existing lesson

**Append to** `<repo-root>/pr-reviews/pending-lessons.md`:

```markdown
## <date> — Pending: <Candidate rule>

**Confidence**: 2 PRs
**Type**: contrast / cluster / contradiction
**Scope**: `**/*.ts`

### Why
<reason>

### Evidence
- PR #123 (verdict: false-positive): ...
- PR #156 (verdict: false-positive): ...

### Proposed lesson
<full markdown lesson body>

### Action
[ ] approve  [ ] reject  [ ] edit and approve

---
```

User reviews `pending-lessons.md` periodically and manually promotes approved entries.

---

## Phase 7: Report

Print summary:

```
📋 Review feedback for PR #123

Findings on PR: 8
  ✓ kept: 4 (3 from human overlap, 1 from reply)
  ✗ false-positive: 2
  ⊘ dropped: 1
  ? unclassified: 1 (skipped)

Missed by AI (from human reviewers): 2
  - performance × 1
  - security × 1

Logged to: <repo-root>/pr-reviews/2026-04.jsonl

Lessons:
  ✅ Auto-promoted: 1
     - ~/Documents/llm-wiki/wiki/review-lessons/dont-flag-strict-null-checks-ts.md
  📝 Queued for review: 2
     - See <repo-root>/pr-reviews/pending-lessons.md

Tip: commit pr-reviews/ to share feedback across machines and teammates.
```

---

## Guardrails

- **Never silently overwrite a wiki lesson.** Contradictions go to pending.
- **Distinct-PR requirement** — confirmations across the same PR don't compound; one bad classification session can't promote a lesson.
- **No bot replies count** — filter by `__typename: Bot` and `[bot]` suffix.
- **No self-replies** — if the AI's own author replies to its own finding, ignore (could be a re-run).
- **Skip approval boilerplate** — lgtm, 👍, "approved", emoji-only, "thanks for the review".
- **Idempotent** — running this twice on the same PR should produce the same JSONL entries (dedupe by `pr_number + review_id` for findings, `pr_number + file + line + reviewer` for missed).
- **Outdated comments** — if `position == null`, use `original_line`. The line moved but the original locus is still meaningful.

---

## Failure Modes

- **No sidecar exists** → suggest re-running `/review-pr` (without `--no-post`) before this command.
- **PR has no comments yet** → suggest waiting; nothing to mine.
- **Wiki not present** → distillation skipped; JSONL still captured. Tell user to set up wiki first.
- **qmd MCP unavailable** → fall back to `Grep` over `wiki/review-lessons/` for existence check.
