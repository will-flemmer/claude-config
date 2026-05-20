---
name: adversarial-plan-premortem
description: Use as a final verification gate after writing a plan, before implementation begins. Dispatches a fresh adversarial subagent that reads the plan cold and runs a pre-mortem — verifying assumptions against the actual codebase, hunting for phantom APIs, bad dependency ordering, missing acceptance criteria, and over-engineering. Produces a severity-rated findings report; the calling agent decides what to revise.
---

# Adversarial Plan Pre-Mortem

## Overview

A standard plan review asks "is this plan good?" A pre-mortem asks "**how does this plan fail?**"

This skill dispatches a fresh subagent — one that has not seen the planning work — to play **devil's advocate** against the plan with the codebase as ground truth. Its job is to assume the plan has already failed during implementation and work backward to find why. The output is a severity-rated findings list returned to the calling agent.

**How to invoke:**
```
Skill({ skill: "adversarial-plan-premortem" })
```

**When to invoke:**
- As the **final step** in `plan-task`, AFTER the plan document is written but BEFORE presenting it as complete
- Before handing a plan to `implement-plan` for execution
- After any agent produces a task breakdown and you want an independent sanity check

**When NOT to invoke:**
- For trivial single-subtask plans — the overhead isn't worth it
- For plans that are explicitly exploratory/spike work — they're expected to be wrong
- As a substitute for `adversarial-plan-review` (the post-implementation version) — that one reviews code; this one reviews plans

---

## Core Principle

> **The reviewer's job is not to approve the plan. It is to find what will go wrong when someone tries to implement it.**

The default failure mode of reviewing a plan is **optimism bias** — assuming the plan's assumptions are correct because they sound reasonable. This skill counteracts that with three forcing functions:

1. **Independence** — the reviewer is a fresh subagent with no planning context
2. **Pre-mortem posture** — the prompt requires imagining the plan has ALREADY failed, then working backward
3. **Codebase as ground truth** — every assumption the plan makes about existing code must be verified against the actual codebase using graph tools

---

## Inputs

The skill requires two inputs from the calling agent:

| Input | Source | Notes |
|-------|--------|-------|
| **Plan file path** | The task plan (e.g., `tasks/task_plan_*.md`) | Absolute path. Contains objective, subtasks, acceptance criteria, execution waves. |
| **Project root** | Current working directory | Where to run graph tools and file reads against. |

If the plan file path is missing, the calling agent must provide it — do not proceed with assumed values.

---

## Execution

The calling agent dispatches **one** subagent using the `Agent` tool with the **Pre-Mortem Reviewer Prompt** (below).

### Single-subagent dispatch (default)

```javascript
Agent({
  subagent_type: "general-purpose",
  description: "Pre-mortem review of <plan-name>",
  prompt: PREMORTEM_REVIEWER_PROMPT  // see template below, with inputs interpolated
})
```

### Parallel dispatch (for large plans with 5+ subtasks)

For plans with many subtasks touching distinct subsystems, dispatch one subagent per review dimension **in a single message**:

- Subagent A: Assumption auditing (phantom APIs, missing code)
- Subagent B: Dependency ordering and wave correctness
- Subagent C: Completeness and edge case coverage
- Subagent D: Complexity and risk assessment

Each receives the same plan, but is scoped to one lens. The calling agent merges their findings before reporting.

---

## The Pre-Mortem Reviewer Prompt

The calling agent must pass a prompt structured like this to the subagent. Interpolate `{{plan_file}}` into the placeholder. Do not summarize or shorten — the rules below are load-bearing.

````markdown
You are an **adversarial plan reviewer** conducting a pre-mortem. You have NOT seen the planning process that produced this document. Your job is to find what will go wrong when someone tries to implement this plan — not to approve it.

## Your Posture

Imagine it is two weeks from now. Implementation of this plan has failed. Engineers wasted days on rework. Your job is to explain — from the plan alone and the actual codebase — **why it failed**. What did the plan get wrong? What did it assume that wasn't true? What did it leave out?

You are NOT trying to be helpful or encouraging. You are trying to **prevent wasted implementation effort**.

## Your Inputs

1. **Plan**: Read `{{plan_file}}` in full. Extract:
   - The stated objective
   - Every subtask (numbered) with its file references and acceptance criteria
   - The execution waves (dependency ordering)
   - Any noted risks or assumptions
   - Any non-goals or explicit scope limits

2. **Codebase state**: Use graph tools and file reads to verify the plan's claims about existing code. This is your ground truth.

## Review Dimensions (in priority order)

Work through these in order. Do not skip to later dimensions until earlier ones are exhausted.

### 1. Assumption Auditing  [highest priority]

This is the **unique value** of this review. A generic plan reviewer cannot do this; you have access to the actual codebase.

Extract EVERY assumption the plan makes about existing code:
- File paths it references → do they exist?
- Functions/classes/APIs it says to call or modify → do they exist? Do they have the expected signature?
- Patterns it says to follow ("like how X does it") → does X actually work that way?
- Dependencies it relies on → are they installed? Correct version?

For each assumption, verify using graph tools:
```
mcp__code-review-graph__semantic_search_nodes_tool({ query: "<API name>", limit: 5 })
mcp__code-review-graph__query_graph_tool({ pattern: "file_summary", target: "<file path>" })
```

If graph returns nothing, fall back to:
```bash
grep -rn "functionName" --include="*.ts" src/
```

If STILL nothing: this is a **CRITICAL** finding — the plan references code that doesn't exist.

Also check:
- Does the plan assume a naming convention or pattern that the codebase doesn't follow?
- Does the plan assume a test framework, build tool, or config format that doesn't match reality?
- Does the plan reference documentation or architecture docs that are outdated or missing?

### 2. Dependency Ordering & Wave Correctness

For the execution waves:
- **Circular dependencies**: Does subtask A depend on B while B depends on A (directly or transitively)?
- **File conflicts**: Do two subtasks in the same wave modify the same files? This will cause merge conflicts in parallel execution.
- **Missing dependencies**: Does subtask N assume output from subtask M, but M isn't listed as a dependency?
- **Build ordering**: If subtask 3 adds a type that subtask 4 imports, are they in the right wave order?

Use graph tools to trace actual import chains:
```
mcp__code-review-graph__query_graph_tool({ pattern: "importers_of", target: "<file>" })
mcp__code-review-graph__get_impact_radius_tool({ target: "<file>", depth: 2 })
```

### 3. Completeness & Acceptance Criteria

For each subtask's acceptance criteria:
- **Testable?** Can you write a test that unambiguously passes or fails for this criterion?
- **Specific?** "Works correctly" is not a criterion. "Returns 404 for non-existent users" is.
- **Missing edge cases?** What happens with empty input, null values, concurrent access, error states?
- **Missing subtasks?** Is there work implied by the objective that no subtask covers? (e.g., migrations, config changes, env vars, CI updates)

### 4. Complexity & Over-Engineering  [lowest priority — don't crowd out the above]

- Could the plan achieve its objective with fewer subtasks or simpler architecture?
- Does it introduce abstractions, patterns, or infrastructure beyond what the task requires?
- Are any subtasks "nice to have" rather than necessary for the stated objective?
- Is the estimated complexity (Simple/Medium/Complex) calibrated correctly?

Cap findings in this dimension at 2-3.

## Rules of Engagement

1. **Name the specific cost** for every finding. "The plan could be better" is not a finding. "Subtask 3 calls `UserService.batchUpdate()` which doesn't exist — implementation will block until it's created, adding ~1 day of unplanned work" is a finding.
2. **Cite evidence** for every finding. Plan section + codebase evidence (file:line or "grep returned nothing").
3. **Verify before claiming**: if you suspect an API doesn't exist, actually search for it. Don't speculate.
4. **No manufactured concerns**: if the plan is genuinely solid, say so — but justify it with what you checked.
5. **You may use tools**: read any file, grep, run graph queries. Verify instead of speculating.
6. **Distinguish blocking from non-blocking**: a phantom API blocks immediately; a vague acceptance criterion causes problems later.

## Severity Rubric

| Severity | Definition | Examples |
|----------|------------|----------|
| **CRITICAL** | Plan assumes code/APIs that don't exist; implementation cannot proceed without unplanned work | Subtask 3 calls `UserService.batchUpdate()` — function doesn't exist; Plan references `src/auth/` directory — doesn't exist |
| **HIGH** | Wrong dependency ordering or missing subtask; will cause significant rework during implementation | Wave 2 subtask imports type created in Wave 2 sibling; No subtask for DB migration but schema changes are required |
| **MEDIUM** | Vague acceptance criteria or missing edge cases; increases scope creep and ambiguity during implementation | "Handle errors properly" — which errors? What's "properly"?; No consideration of concurrent access to shared resource |
| **LOW** | Unnecessary complexity or suboptimal approach; not a blocker but wastes effort | Three subtasks could be collapsed into one; Plan creates abstraction layer for single use case |

**Default to CRITICAL for phantom APIs.** Code that doesn't exist is not a "MEDIUM, it can probably be added."

## Output Format

Return your review in EXACTLY this Markdown structure. The calling agent will parse it.

```markdown
# Pre-Mortem Review: <one-line summary>

## Assumption Verification

| # | Plan Assumption | Evidence | Status |
|---|----------------|----------|--------|
| 1 | <what the plan claims exists or works a certain way> | <file:line or "not found"> | ✅ Verified / ⚠️ Partially correct / ❌ Not found |
| 2 | ... | ... | ... |

## Wave Ordering Check

| Wave | Subtasks | File Conflicts | Dependency Issues |
|------|----------|---------------|-------------------|
| 1 | S1, S2 | None | None |
| 2 | S3, S4 | S3 and S4 both modify `src/api/routes.ts` | S4 imports type from S3 |

## Findings

### CRITICAL
1. **<short title>** — Plan section: <reference>
   - **What**: <specific issue>
   - **Evidence**: <what you checked and found>
   - **Impact**: <what goes wrong during implementation>
   - **Suggested plan revision**: <concrete change to the plan>

### HIGH
1. ...

### MEDIUM
1. ...

### LOW
1. ...

## What I Checked (Negative Space)
Brief list of things you verified are NOT problems:
- Searched for `<API>`: confirmed exists at `file:line`
- Traced imports for `<file>`: dependency chain is correct
- Verified wave ordering: topological sort is valid
- ...

## Verdict
- [ ] Plan is sound (zero CRITICAL/HIGH, acceptance criteria are testable)
- [ ] Plan needs revision (CRITICAL or HIGH findings must be addressed before implementation)
- [ ] Plan needs rethinking (fundamental assumptions are wrong; replanning recommended)

**Reasoning**: <2-3 sentences>
```

## Anti-Rationalization Checklist (before returning your review)

Re-read your own draft and ask:

- [ ] Did I verify EVERY file path and API reference in the plan against the actual codebase?
- [ ] Did I check the execution wave ordering for conflicts and missing dependencies?
- [ ] Did I evaluate whether each acceptance criterion is specific enough to test?
- [ ] Did I name the implementation cost for every finding?
- [ ] Did I default to CRITICAL for phantom APIs, or did I soften to HIGH because "it's probably easy to add"?
- [ ] If I found zero issues, did I justify what I checked to rule out optimism bias?

If any answer is unsatisfying, revise before returning.
````

---

## Calling Agent's Responsibilities

After receiving the subagent's report, the calling agent MUST:

1. **Surface the findings to the user** — do not silently swallow or summarize-away CRITICAL/HIGH findings. Quote the report's `## Findings` section.
2. **Revise the plan if needed** — CRITICAL findings mean the plan's assumptions are wrong; update the task document before proceeding to implementation.
3. **Append findings to the plan document** — add a `## Pre-Mortem Review` section at the end of the task file so `implement-plan` can see what was checked and what risks remain.
4. **Do NOT hand the plan to `implement-plan`** if CRITICAL findings exist — those represent unplanned work that will block implementation.

### Revision loop

If CRITICAL or HIGH findings exist:
1. Revise the affected plan sections (fix phantom APIs, reorder waves, add missing subtasks)
2. Re-dispatch the pre-mortem on the revised plan
3. Cap at 2 iterations. If still unresolved, surface to user for manual review.

MEDIUM findings: note them in the plan as known risks. Do not block on them.
LOW findings: include in report, defer unless trivial to fix in the plan.

---

## Common Failure Modes (of this skill itself)

| Failure | Smell | Fix |
|---------|-------|-----|
| **Rubber-stamping** | Report says "plan looks solid" with no assumption verification table | Re-dispatch with explicit instruction: "Your previous review verified zero assumptions — list every API reference in the plan and check each one." |
| **Speculation without verification** | Findings say "this might not exist" without actually searching | Re-dispatch: "Every finding must include evidence from a graph query or grep. No speculation." |
| **Nit-flooding** | 10 LOW findings, 0 CRITICAL/HIGH | The reviewer dodged the hard work. Re-dispatch scoped to dimensions 1-2 only. |
| **Hallucinated codebase state** | Report claims an API exists/doesn't exist incorrectly | Spot-check the top 2 CRITICAL findings against the actual codebase before acting on them. |
| **Plan-blindness** | Report skips the Assumption Verification table | Re-dispatch; this is the unique value — without it, this is just generic plan feedback. |

---

## Integration with `plan-task`

In `plan-task`, this skill runs at **Step 9 (Pre-Mortem Review)**, AFTER the plan document is fully written (Step 8) and BEFORE the output summary (Step 10).

Flow:
1. Plan document written with all subtasks, waves, and acceptance criteria
2. Invoke this skill → dispatch pre-mortem subagent
3. Receive report
4. If CRITICAL findings: revise plan, re-run (max 2 iterations)
5. If HIGH findings: revise plan or note as known risk
6. Append `## Pre-Mortem Review` section to the plan document
7. Proceed to output summary

Skip with `SKIP_PLAN_REVIEW=1` for speed or when the plan is intentionally exploratory.

This skill does **not** replace `adversarial-plan-review` (the post-implementation version). Run this one to catch bad assumptions before writing code; run that one to catch bugs after writing code.

---

## The Bottom Line

A well-structured plan looks convincing. It has subtasks, dependencies, acceptance criteria, execution waves. It reads like it will work.

But a plan is a set of assumptions about the codebase. If those assumptions are wrong — if the APIs it references don't exist, if the dependencies it claims are inverted, if the acceptance criteria it lists are untestable — then implementation will fail in expensive, time-consuming ways.

**This skill exists to find the gap between "the plan looks right" and "the plan will actually work."**

The reviewer's job is to disappoint you productively. If it never does, it isn't working.
