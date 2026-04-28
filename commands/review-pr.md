---
description: Review a GitHub PR for code quality, security, and best practices
argument-hint: <pr-url> [--no-post] [--public]
allowed-tools: Read, Write, Bash(gh:*), Bash(open:*), Bash(jq:*), Bash(mkdir:*), Bash(date:*), Bash(uuidgen:*), Bash(shasum:*), Bash(echo:*), Bash(cat:*), Bash(test:*), Grep, Glob, mcp__sequential-thinking__sequentialthinking, mcp__context7__resolve-library-id, mcp__context7__get-library-docs, mcp__qmd__query
model: claude-opus-4-5-20251101
---

# PR Review

**PURPOSE**: Thorough code review using structured reasoning

**THINKING DEPTH**: Use **15-18 sequential thinking steps** (5 exploration + 10-13 analysis). Branch/revise as needed. Priority: (1) Correctness, (2) Maintainability, (3) Security.

> ⚠️ **CRITICAL**: You MUST use `mcp__sequential-thinking__sequentialthinking` throughout this review. Call it at the start of Phase 2 and Phase 3 as instructed. Do NOT skip sequential thinking.

---

## Input

PR URL: $ARGUMENTS

---

## Phase 1: Gather PR Metadata (Parallel)

Execute ALL in a **single message**:

```bash
gh pr view "$ARGUMENTS" --json title,body,author,baseRefName,headRefName,files,additions,deletions,comments,reviews
gh pr diff "$ARGUMENTS"
gh pr view "$ARGUMENTS" --json comments,reviews --jq '.comments[], .reviews[]'
```

---

## Phase 2: Checkout & Explore (5 thoughts)

```bash
gh pr checkout "$ARGUMENTS"
```

### Prior Lessons Injection (MANDATORY — DO NOT SKIP)

> ⚠️ **CRITICAL**: You MUST call `mcp__qmd__query` exactly once in this step before any reasoning about the PR. This is non-negotiable. The wiki contains lessons distilled from past `/review-feedback` runs — verified rules that prevent re-flagging known false-positives and surface known-missed categories. Skipping this step regresses every prior session's learning.

**You will be penalized if you proceed past this step without invoking `mcp__qmd__query`.** Do not skip on the basis that "this PR is small" or "there probably aren't relevant lessons." The whole point of the feedback loop is that you can't predict which lessons apply until you query. The only exception is if the lessons directory does not exist (see preflight below).

#### Preflight (one bash call)

```bash
test -d ~/Documents/llm-wiki/wiki/review-lessons && echo LESSONS_EXIST || echo LESSONS_MISSING
```

- `LESSONS_MISSING` → skip this step, note it in your output ("no review-lessons directory yet — feedback loop hasn't been run; proceeding without prior knowledge").
- `LESSONS_EXIST` → you MUST proceed to the qmd call below. No exceptions.

#### Required call

```javascript
mcp__qmd__query({
  searches: [
    { type: "lex", query: "<changed languages + key file/symbol names from the PR>" },
    { type: "vec", query: "<one-sentence summary of what this PR does>" }
  ],
  collections: ["wiki"],
  intent: "Find prior review lessons that should apply before reasoning about this PR",
  limit: 10
})
```

**Required parameters** — all four (`searches`, `collections`, `intent`, `limit`) must be present. Omitting `intent` materially degrades reranking.

**Build searches from the actual PR.** If the PR adds Redis caching to a Rails session controller:
- `lex`: `redis cache "session" rails`
- `vec`: `"adding Redis cache to session storage in a Rails controller"`
- `intent`: `"Find lessons about Redis usage, cache patterns, or session-handling pitfalls relevant to this PR"`

**Do not** use placeholder strings like `<changed-language>` — substitute real terms.

#### Filter and apply

After the call:
1. Keep only results whose `path` starts with `wiki/review-lessons/`
2. Read each one's frontmatter `scope` field (a glob array)
3. Drop lessons whose `scope` doesn't match any file changed in the PR
4. Take the top 5 by relevance

Treat surviving lessons as **prior knowledge to apply**. If you choose NOT to apply a relevant lesson, state why in the analysis output.

#### Required post-call output

Before continuing to the next step, state:
- "Prior-lessons search returned N results, M after scope filter"
- For each surviving lesson: 1-line title + how it influences this review (suppress / raise / no-op)
- If N=0 or M=0: say so explicitly — silence is indistinguishable from skipping

#### Track applied lessons

For each retrieved lesson you actually used, record:
- The lesson's file path
- Which finding `review_id`s it influenced

This list becomes the `applied_lessons` array in the sidecar (Phase 4, Step 2). It drives `/review-feedback`'s `applied_count` / `dropped_count` updates and the Tricorder kill switch in `wiki-lint`.

### Context7: Fetch Library Documentation (If Applicable)

**When to use**: If the PR modifies code that uses external libraries (React, Next.js, Prisma, etc.) and you need to verify correct API usage or check for deprecated patterns.

**How to use**:
1. Identify external libraries involved in changed code
2. For each library needing verification:
   ```javascript
   // First, resolve the library ID
   mcp__context7__resolve-library-id({ libraryName: "library-name" })

   // Then fetch relevant docs (optional topic filter)
   mcp__context7__get-library-docs({
     context7CompatibleLibraryID: "<resolved-id>",
     topic: "hooks"  // optional: focus on specific topic
   })
   ```

**Skip if**: PR only touches internal code, configuration, or well-known stable APIs.

### MANDATORY: Start Sequential Thinking NOW

**You MUST call `mcp__sequential-thinking__sequentialthinking` before proceeding.** Do not skip this step.

```javascript
// EXECUTE THIS TOOL CALL:
mcp__sequential-thinking__sequentialthinking({
  thought: "Beginning exploration. Modified files: [list]. Will explore: files, call sites, dependencies, tests, standards.",
  thoughtNumber: 1,
  totalThoughts: 5,
  nextThoughtNeeded: true
})
```

**Continue using sequential thinking for ALL exploration steps below.** Each step = 1 thought.

### Exploration Steps

**Step 1: Read Modified Files & Identify Changes**
- Read ENTIRE file for each modified file (parallel)
- List all changed functions/classes/exports
- Note signature changes

**Step 2: Trace Call Sites & Dependencies**
- Search for all usages of changed code (parallel Grep)
- Read imported dependencies
- Identify breaking change risks

**Step 3: Find Patterns & Module Structure**
- Search for similar implementations
- Read module entry points
- Check for established patterns

**Step 4: Review Tests & Standards**
- Find and read related tests (parallel)
- Read CLAUDE.md and config files
- Note testing patterns

**Step 5: Synthesize Findings**
- Summarize concerns from exploration
- List patterns followed/violated
- Identify red flags for analysis

---

## Phase 3: Analysis (10-13 thoughts)

### MANDATORY: Invoke Skills and Continue Sequential Thinking

**Step 1:** Invoke the unit-testing skill:
```
Skill({ skill: "unit-testing" })
```

**Step 2:** Start a NEW sequential thinking chain for analysis. **You MUST call this:**

```javascript
// EXECUTE THIS TOOL CALL:
mcp__sequential-thinking__sequentialthinking({
  thought: "Analyzing PR: [title]. [N] files, +[add]/-[del]. Priority: correctness → maintainability → security.",
  thoughtNumber: 1,
  totalThoughts: 12,
  nextThoughtNeeded: true
})
```

**Continue sequential thinking through ALL analysis steps.** Each step = 1+ thoughts.

### Analysis Steps

**Steps 1-2: Understanding**
- Scope, intent, architecture impact
- Synthesize exploration findings

**Steps 3-6: Code Correctness (HIGHEST PRIORITY)**
- **Logic**: Happy path, conditionals, loops, data flow
- **Edge cases**: null/empty/boundary inputs, error handling
- **Types**: Type safety, coercion bugs, nullable handling
- **Async**: Promises, race conditions, error propagation

**Step 7: API Design**
- Redundant parameters? (e.g., `func(user, user.id)`)
- Mismatched parameter risks?
- Flag as MEDIUM severity

**Step 8: Security & Performance**
- OWASP Top 10 (injection, auth, access control)
- Complexity, N+1 queries, blocking operations

**Step 9: Test Quality**
Flag these anti-patterns:
- Configuration tests (test wiring, not behavior) → HIGH
- Redundant/duplicate tests → MEDIUM
- Missing critical path tests → HIGH

Key question: "If this test passes, does it prove the feature works?"

**Steps 10-11: Maintainability (SECOND PRIORITY)**
- Readability: Can you understand it in 5 min?
- Changeability: Hidden dependencies, coupling?
- DRY violations, unnecessary complexity
- Project standards compliance

**Step 12: Synthesis & Verdict**
- Prioritize findings by severity
- Distinguish blockers vs suggestions
- Final confidence check

### Thinking Guidelines

- **Branch** when uncertain or exploring alternatives
- **Revise** when later context changes assessment
- **Extend** for large/complex PRs (set `needsMoreThoughts: true`)

---

## CRITICAL: Don't Rationalize Away Findings

**Report concerns. Don't assume the author had good reasons.**

| ❌ Don't | ✅ Do |
|----------|-------|
| "Probably intentional" | Flag it, let author explain |
| "Must have been tested" | Flag suspicious patterns |
| "I could be wrong" | Report with your reasoning |

**Rule**: If it MIGHT be an issue, flag it. False positive cost < false negative cost.

---

## Severity Guide

| Severity | Criteria | Action |
|----------|----------|--------|
| **CRITICAL** | Logic bug, security vuln, data loss, crash | **MUST fix** |
| **HIGH** | Edge case failure, race condition, false-confidence tests, redundant tests, API design issues, readability issues, maintainability issues | Should fix |
| **MEDIUM** | Performance | Consider fixing |
| **LOW/NIT** | Style, minor improvements | Optional |

---

## Output Format: HTML Report

**Skip this entire phase if posting to PR (the default).** When findings will be posted in Phase 4, the HTML report is redundant — the PR comment thread is the canonical surface.

Only generate the HTML report when:
- `$ARGUMENTS` contains `--no-post`, OR
- Phase 4 was skipped for any reason (public-repo guard tripped, etc.)

If posting, jump directly to Phase 4.

---

Generate a styled HTML report using the template at `~/.claude/commands/review-pr/template.html`.

### Step 1: Read the HTML Template

```bash
cat ~/.claude/commands/review-pr/template.html
```

### Step 2: Generate HTML Content

Replace placeholders with actual review data:

| Placeholder | Value |
|-------------|-------|
| `{{PR_TITLE}}` | PR title from metadata |
| `{{PR_URL}}` | Full PR URL |
| `{{PR_AUTHOR}}` | Author login |
| `{{PR_BRANCH}}` | `headRefName` -> `baseRefName` |
| `{{CRITICAL_COUNT}}` | Number of critical issues |
| `{{HIGH_COUNT}}` | Number of high issues |
| `{{MEDIUM_COUNT}}` | Number of medium issues |
| `{{LOW_COUNT}}` | Number of low/nit issues |
| `{{CRITICAL_SECTION}}` | HTML for critical issues (see below) |
| `{{HIGH_SECTION}}` | HTML for high issues |
| `{{MEDIUM_SECTION}}` | HTML for medium issues |
| `{{LOW_SECTION}}` | HTML for low issues |
| `{{APPROVE_SELECTED}}` | `selected` if approving, else empty |
| `{{CHANGES_SELECTED}}` | `selected` if requesting changes, else empty |
| `{{VERDICT_SUMMARY}}` | Brief explanation of verdict |

### Section HTML Template

For each severity level with issues, generate:

```html
<div class="severity-section severity-{level}">
    <div class="severity-header">
        <svg class="severity-icon" viewBox="0 0 20 20" fill="currentColor">
            <!-- Use appropriate icon -->
        </svg>
        {LEVEL} ({count})
    </div>
    <div class="issues-list">
        <!-- Issues go here -->
    </div>
</div>
```

### Issue HTML Template

For each issue:

```html
<div class="issue">
    <div class="issue-location">
        <svg class="file-icon" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M4 4a2 2 0 012-2h4.586A2 2 0 0112 2.586L15.414 6A2 2 0 0116 7.414V16a2 2 0 01-2 2H6a2 2 0 01-2-2V4z" clip-rule="evenodd"/>
        </svg>
        {file_path}:{line_number}
    </div>
    <div class="issue-title">{Issue Title}</div>
    <div class="issue-description">
        {Detailed description with <code>inline code</code> and:}
        <pre>{code blocks if needed}</pre>
    </div>
</div>
```

### Step 3: Save and Open Report

```bash
# Save to temp file with timestamp
output_file="/tmp/pr-review-$(date +%Y%m%d-%H%M%S).html"
```

Use the Write tool to save the generated HTML to `$output_file`, then:

```bash
open "$output_file"  # Opens in default browser
```

**Guidelines**: Be specific (file:line), explain WHY, suggest fixes, skip linter-catchable issues. Omit empty severity sections entirely (don't show section header if no issues).

---

## Phase 4: Post Findings to PR (default ON; skip if `--no-post` in arguments)

This phase enables the feedback loop. Each finding is posted as a comment on the PR with a stable `review_id` so `/review-feedback` can later mine the thread for verdicts.

**Skip this phase entirely if `$ARGUMENTS` contains `--no-post`.** Tell the user findings were not posted.

### Step 1: Assign stable review_ids

For each finding, generate a deterministic id:

```bash
# review_id = first 12 chars of sha256(pr_url + file + line + title)
echo -n "<pr-url>|<file>|<line>|<title>" | shasum -a 256 | cut -c1-12
```

Stable ids let re-runs of `/review-pr` skip already-posted findings (check sidecar before posting).

### Step 2: Build the sidecar

**Path: `<repo-root>/pr-reviews/sidecars/<pr-number>.json`** (committed to the repo, shared across machines and teammates).

```bash
# Determine repo root from the checked-out PR
repo_root=$(git rev-parse --show-toplevel)
mkdir -p "$repo_root/pr-reviews/sidecars"
```

**Public-repo guard.** Before writing, check repo visibility:

```bash
visibility=$(gh repo view --json visibility --jq '.visibility')
```

If `visibility == "PUBLIC"`, the JSONL log will contain verbatim human-reviewer comments and become public. **Refuse to proceed unless `$ARGUMENTS` contains `--public`.** Tell the user:
- This repo is public; review feedback will be committed and visible to anyone
- Re-run with `--public` to acknowledge, or `--no-post` to skip posting entirely

If `--public` is passed (or repo is private/internal), proceed.

Schema:

```json
{
  "pr_url": "https://github.com/owner/repo/pull/123",
  "pr_number": 123,
  "reviewed_at": "2026-04-28T14:32:00Z",
  "head_sha": "<commit sha at review time>",
  "applied_lessons": [
    {
      "lesson_path": "wiki/review-lessons/dont-flag-strict-null-checks-ts.md",
      "lesson_title": "Don't flag missing null checks in TS strict mode",
      "influenced_findings": ["abc123def456"]
    }
  ],
  "findings": [
    {
      "review_id": "abc123def456",
      "severity": "high",
      "file": "src/auth.ts",
      "line": 42,
      "title": "Missing null check on user.id",
      "body": "<full markdown finding body>",
      "posted_comment_id": null,
      "posted_comment_url": null,
      "posted_at": null
    }
  ]
}
```

**`applied_lessons`** — lessons retrieved during Phase 2 prior-lessons injection that influenced findings. List which finding `review_id`s were affected (suppressed or generated based on the lesson). This lets `/review-feedback` increment `applied_count` on the lesson and `dropped_count` if the influenced finding turned out to be a false-positive.

If sidecar already exists for this PR, merge: keep posted ids, only post net-new findings.

### Step 3: Post each finding

**Comment format — keep it tight.** PR comments are conversational, not reports. Default 1–3 sentences. Inline code only when essential. No severity headers, no "Issue:" / "Fix:" / "Why:" labels, no horizontal rules, no emojis beyond a single severity prefix.

**Shape:**

```
**[severity]** <one-sentence problem statement>. <optional second sentence: why it matters or suggested fix>.

<!-- review-id: abc123def456 -->
```

Where `[severity]` is one of `critical` / `high` / `medium` / `nit`. Example:

```
**high** `user.id` can be undefined here when the session is anonymous — this will throw at runtime.

<!-- review-id: abc123def456 -->
```

**Allowed expansions** (use sparingly):
- One short code block (≤8 lines) when the fix isn't obvious from prose
- One bullet list (≤4 items) when listing distinct cases
- A single inline link to a referenced file/line elsewhere

**Forbidden:**
- Multi-paragraph explanations
- Restating what the code does
- "Consider...", "You might want to...", "It would be nice if..."
- Hedge phrases ("I could be wrong, but...", "This may or may not be an issue")
- Praise ("Great work!", "Nice refactor")
- "Suggested fix" sections that just rewrite the line in prose
- Cross-referencing other findings ("see also #2") — each comment stands alone

**For each finding NOT already posted, append the marker to the body:**

```
<!-- review-id: abc123def456 -->
```

**Inline (file:line known)** — use `gh api` to post a review comment on the diff:

```bash
gh api \
  -X POST \
  /repos/{owner}/{repo}/pulls/{pr_number}/comments \
  -f body="<finding body>

<!-- review-id: abc123def456 -->" \
  -f commit_id="<head_sha>" \
  -f path="src/auth.ts" \
  -F line=42 \
  -f side=RIGHT
```

**General (no file:line)** — issue comment on the PR:

```bash
gh pr comment "$ARGUMENTS" --body "<finding body>

<!-- review-id: abc123def456 -->"
```

Capture the returned `id` and `html_url` from the API response and write back to the sidecar (`posted_comment_id`, `posted_comment_url`, `posted_at`).

### Step 4: Save the sidecar

Write the completed sidecar atomically:

```bash
# Write to a tmp file first, then mv — avoids partial writes
```

### Step 5: Report

Tell the user:
- Number of findings posted (and to which PR)
- Sidecar path (`<repo-root>/pr-reviews/sidecars/<pr>.json`)
- That `/review-feedback <pr-url>` will mine responses later
- That the sidecar is committable — they should `git add pr-reviews/` if they want to share/sync feedback across machines or teammates

---

## Final Step

Summarize, depending on path taken:

**If posted to PR (default):**
1. Findings posted: N (link to PR)
2. Sidecar: `<repo-root>/pr-reviews/sidecars/<pr>.json`
3. Next: run `/review-feedback <pr-url>` after the PR thread has activity to capture verdicts and update the wiki.

**If `--no-post` (HTML-only):**
1. HTML report path
2. Findings: N (not posted)
3. To enable the feedback loop, re-run without `--no-post`.
