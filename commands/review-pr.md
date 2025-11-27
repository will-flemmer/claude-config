---
description: Review a GitHub PR for code quality, security, and best practices
argument-hint: <pr-url>
allowed-tools: Read, Bash(gh:*), Grep, Glob, mcp__sequential-thinking__sequentialthinking
model: claude-opus-4-5-20251101
---

# PR Review

**PURPOSE**: Thorough code review using structured reasoning

**THINKING DEPTH**: Use **15-18 sequential thinking steps** (5 exploration + 10-13 analysis). Branch/revise as needed. Priority: (1) Correctness, (2) Maintainability, (3) Security.

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

**Use sequential thinking with parallel tool calls within each step.**

```javascript
mcp__sequential-thinking__sequentialthinking({
  thought: "Beginning exploration. Modified files: [list]. Will explore: files, call sites, dependencies, tests, standards.",
  thoughtNumber: 1,
  totalThoughts: 5,
  nextThoughtNeeded: true
})
```

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

**Invoke unit-testing skill before analyzing tests:**
```
Skill({ skill: "unit-testing" })
```

```javascript
mcp__sequential-thinking__sequentialthinking({
  thought: "Analyzing PR: [title]. [N] files, +[add]/-[del]. Priority: correctness → maintainability → security.",
  thoughtNumber: 1,
  totalThoughts: 12,
  nextThoughtNeeded: true
})
```

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

## Output Format

```markdown
# PR Review

**PR**: [URL]

## CRITICAL

### Issue 1 - path/to/file:42
<description of issue>

### Issue 2 - path/to/file:78
<description of issue>

## HIGH

### Issue 1 - path/to/file:120
<description of issue>

## MEDIUM

### Issue 1 - path/to/file:55
<description of issue>

## LOW

### Issue 1 - path/to/file:15
<description of issue>

## Verdict
- [ ] **Approve** | [ ] **Request Changes** | [ ] **Comment**
```

**Guidelines**: Be specific (file:line), explain WHY, suggest fixes, skip linter-catchable issues. Omit empty severity sections.

---

## Final Step

Ask: Post as PR comment (`gh pr comment`) or keep here?
