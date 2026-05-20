---
description: Analyze tasks and create actionable implementation plans with codebase + wiki research
argument-hint: <task-description>
allowed-tools: Read, Write, Edit, Bash, mcp__qmd__query, mcp__sequential-thinking__sequentialthinking, mcp__code-review-graph__semantic_search_nodes_tool, mcp__code-review-graph__query_graph_tool, mcp__code-review-graph__get_architecture_overview_tool, mcp__code-review-graph__list_communities_tool, mcp__code-review-graph__get_impact_radius_tool, mcp__code-review-graph__find_large_functions_tool
model: claude-opus-4-6
---

# plan-task — Execution Procedure

**DO NOT call `EnterPlanMode`.** This command produces task files, not a plan-mode session.

Reference material (examples, templates, troubleshooting): `commands/plan-task/reference.md`

---

## Tool Priority

**Graph tools are your PRIMARY codebase discovery mechanism.**

| Priority | Tools | Use for |
|----------|-------|---------|
| 1st | `semantic_search_nodes_tool`, `query_graph_tool`, `get_architecture_overview_tool` | All codebase discovery, API lookup, relationship tracing |
| 2nd | `Read` | Reading specific files after graph identifies them |
| 3rd | `Bash` with `grep`/`find` | ONLY when graph has no coverage (config files, string literals, unindexed content) |

**Grep and Glob are NOT in allowed-tools.** Use `Bash` grep as a last resort only.

---

## Execution Steps

Execute these steps in order. Each step lists the exact tool calls to make.

### Step 1 — Session Setup

Generate session ID from today's date: `plan_YYYYMMDD_HHMMSS`

Create two files (use templates from `commands/plan-task/templates/`):
- `tasks/session_context_<session_id>.md`
- `tasks/<descriptive-name>_<session_id>.md`

### Step 2 — Clarifying Questions

Ask 3-5 questions if the task is vague (< 25 words, unclear scope, missing constraints).
Skip if the task is specific and well-defined.

### Step 3 — Parallel Discovery (ONE message, ALL calls)

Issue ALL of these in a single message:

```
mcp__code-review-graph__get_architecture_overview_tool({})

mcp__code-review-graph__semantic_search_nodes_tool({
  query: "<keywords from task>",
  limit: 20
})

mcp__qmd__query({
  searches: [
    { type: "lex", query: "<exact terms from task>" },
    { type: "vec", query: "<task as natural-language question>" }
  ],
  collections: ["wiki"],
  intent: "<what we want to learn from prior wiki notes>",
  limit: 10
})
```

Wiki preflight: run `test -d ~/Documents/llm-wiki/wiki && echo WIKI_EXISTS || echo WIKI_MISSING` first. Skip qmd if WIKI_MISSING.

After results: state "Wiki search returned N results" and summarize relevant findings.

### Step 4 — Read Project Docs

Read in parallel (single message): README.md, ARCHITECTURE.md, CONTRIBUTING.md, package.json — whichever exist.

### Step 5 — API Discovery (Graph)

For each module/service the task will touch:

```
mcp__code-review-graph__query_graph_tool({
  pattern: "file_summary",
  target: "<file path from step 3 results>"
})

mcp__code-review-graph__query_graph_tool({
  pattern: "tests_for",
  target: "<module name>"
})

mcp__code-review-graph__semantic_search_nodes_tool({
  query: "<specific function or class name>",
  kind: "Function",
  limit: 10
})
```

Run multiple `query_graph` calls in parallel when they're independent.

**Document every API as:**
- `functionName` — `file:line` — signature ✅ EXISTS
- `functionName` — ❌ MISSING — needs creation (add as subtask)

### Step 6 — Validate Assumptions

For each API/import in your draft plan, confirm via graph:

```
mcp__code-review-graph__semantic_search_nodes_tool({
  query: "<API name>",
  kind: "Function",
  limit: 5
})

mcp__code-review-graph__query_graph_tool({
  pattern: "importers_of",
  target: "<file path>"
})
```

If graph returns nothing for something you expect to exist, THEN use `Bash` grep:
```bash
grep -rn "functionName" --include="*.ts" src/
```

Record results in Validation Results table (see task_doc template).

### Step 7 — Decompose (Sequential Thinking)

Use `mcp__sequential-thinking__sequentialthinking` for 8 thinking steps:

1. Component identification
2. Decomposition into 3-7 subtasks
3. Complexity assessment (Simple / Medium / Complex)
4. Dependency analysis
5. Execution wave computation (topological sort — no two subtasks in same wave modify same files)
6. Risk identification
7. Testing strategy
8. Final review

### Step 8 — Write Task Files

Populate both files with all findings:

**Task doc** must include:
- Verified Technical Foundation (EXISTS / MISSING / BLOCKED tables)
- Subtasks with: objective, depends-on, reference file:line, tests, done-when
- Execution Waves section
- External dependencies

**Session context** must include:
- Clarifications
- Technical decisions from discovery
- Activity log of all steps taken

### Step 9 — Pre-Mortem Review (Final Gate)

Skip if `SKIP_PLAN_REVIEW=1`.

Invoke `adversarial-plan-premortem` with the plan file path. This dispatches a fresh subagent that reads the plan cold and verifies every assumption against the actual codebase.

**Revision loop**: while CRITICAL or HIGH findings remain:
1. Read cited evidence to confirm finding is real (spot-check top 2)
2. If real: revise the plan (fix phantom APIs, reorder waves, add missing subtasks)
3. If hallucinated: skip
4. Re-dispatch pre-mortem review on revised plan
5. Cap at 2 iterations. If still unresolved, surface to user.

MEDIUM findings: note as known risks in the plan. Don't block.
LOW findings: include in report, defer.

**After review**: append a `## Pre-Mortem Review` section to the plan document with the verdict and any remaining findings, so `implement-plan` has visibility.

**Do NOT proceed past this step with unresolved CRITICAL findings.**

### Step 10 — Output Summary

Print:
```
✅ Task Plan Created
Session: tasks/session_context_<id>.md
Plan: tasks/<name>_<id>.md
Subtasks: N | Complexity: X | Waves: Y
Pre-mortem: <verdict — Sound / Revised / Needs attention>
```

---

## Rules

1. **Graph first, always.** Every codebase query starts with a graph tool. Bash grep is a last-resort fallback.
2. **Parallel everything.** Independent tool calls go in one message.
3. **Verify before suggesting.** Every API has a file:line or is marked MISSING.
4. **No phantom APIs.** Never suggest methods based on naming conventions.
5. **Wiki search is mandatory.** Unless ~/Documents/llm-wiki/wiki doesn't exist.
