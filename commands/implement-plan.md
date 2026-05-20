---
description: Implement task plans using TDD methodology with parallel subagents
argument-hint: <plan-file>
allowed-tools: Read, Write, Edit, Bash, mcp__qmd__query, mcp__sequential-thinking__sequentialthinking, mcp__code-review-graph__semantic_search_nodes_tool, mcp__code-review-graph__query_graph_tool, mcp__code-review-graph__get_architecture_overview_tool, mcp__code-review-graph__list_communities_tool, mcp__code-review-graph__get_impact_radius_tool, mcp__code-review-graph__find_large_functions_tool
model: claude-opus-4-6
---

# implement-plan — Execution Procedure

**DO NOT** create git commits, push code, or create PRs. This command is local implementation only.

---

## Skill Invocations (Before Starting)

```
Skill({ skill: "dispatching-parallel-agents" })   // wave execution
Skill({ skill: "software-development" })           // clean code
Skill({ skill: "unit-testing" })                   // TDD
```

Invoke `verification-before-completion` before claiming done.
Invoke `adversarial-plan-review` as final gate (skip if `SKIP_ADVERSARIAL_REVIEW=1`).

---

## Tool Priority

| Priority | Tools | Use for |
|----------|-------|---------|
| 1st | `semantic_search_nodes_tool`, `query_graph_tool` | Finding code, understanding relationships, verifying APIs |
| 2nd | `Read` | Reading specific files after graph identifies them |
| 3rd | `Bash` with `grep`/`find` | ONLY when graph has no coverage |

**Grep and Glob are NOT in allowed-tools.** Use `Bash` grep as a last resort.

---

## Execution Steps

### Step 1 — Parse Plan

- Read `{{plan_file_path}}`
- Extract: objective, subtasks, acceptance criteria
- Parse `## Execution Waves` section — extract wave structure and subtask assignments
- If no waves section: fall back to sequential execution (one subtask at a time)

### Step 2 — Create Session Context

- Session ID: `implement_YYYYMMDD_HHMMSS` (from `<env>` date)
- Create `tasks/session_context_{{session_id}}.md`
- Initialize: objective, wave tracking, subtask tracking, TDD phases

### Step 3 — Execute Waves

**For each wave**, dispatch ALL subtasks in that wave as parallel agents in a single message:

```javascript
Agent({
  description: "Implement Subtask N: [Title]",
  prompt: `You are implementing a single subtask using TDD.

## Subtask
[Full subtask from plan: title, description, criteria, file references]

## TDD Process
1. RED: Write failing tests → run: \`just test path/to/test.spec.ts\` → verify FAIL
2. GREEN: Minimal code to pass → run tests → verify PASS (retry up to 3x)
3. REFACTOR: Clean up → run tests → verify still passing → run: \`just lint <files>\`

## Codebase Discovery
Use graph tools FIRST for any code lookup:
- \`mcp__code-review-graph__semantic_search_nodes_tool\` to find functions/classes
- \`mcp__code-review-graph__query_graph_tool\` with file_summary, callers_of, tests_for
- Fall back to Bash grep ONLY if graph has no results

## Constraints
- Only modify files relevant to THIS subtask
- Follow existing code patterns

## Return
Report: files changed, tests written, test results, lint status, implementation summary`
})
```

### Step 4 — Integration Check (After Each Wave)

- Review each agent's report
- **Conflict detection**: did any agents modify the same files? If so, resolve manually
- **Integration test**: `just test <all-changed-test-files-from-wave>`
- **Lint check**: `just lint <all-changed-files-from-wave>`
- Update session context with wave results

Repeat steps 3-4 for each wave.

### Step 5 — Final Verification

- Run tests for ALL changed files across all waves
- Run linting for ALL changed files
- Verify all subtasks complete

### Step 6 — Cross-Wave Code Review

Invoke `requesting-code-review` to catch integration issues across waves. Fix any issues found, re-run tests.

### Step 7 — Adversarial Review (Final Gate)

Skip if `SKIP_ADVERSARIAL_REVIEW=1`.

Invoke `adversarial-plan-review` with the plan file path and base branch.

**Fix loop**: while HIGH findings remain:
1. Read cited file:line to confirm finding is real
2. If real: fix (tests first, then implement)
3. If hallucinated: skip
4. Re-run `just test` + `just lint`
5. Re-dispatch adversarial review

Cap at 3 iterations. If still unresolved, surface to user.

MEDIUM findings: surface to user, don't auto-fix.
LOW findings: include in report, defer unless trivial.

**Do NOT proceed past this step with unresolved HIGH findings.**

### Step 8 — Finalize

- Set session status to "Completed"
- Record adversarial review iteration count and verdict
- Update activity log

---

## Sequential Fallback

If no `## Execution Waves` section or all subtasks are linearly dependent:

For each subtask in order:
1. RED: Write failing tests, run related tests only
2. GREEN: Implement minimal code, retry up to 3x
3. REFACTOR: Clean up, run tests + lint
4. Mark complete, move to next

---

## TDD Rules

- **RED**: Write failing tests. Verify they fail. Run only related tests.
- **GREEN**: Minimal code to pass. Retry up to 3x. If still failing after 3 retries, invoke `systematic-debugging`.
- **REFACTOR**: Remove duplication, improve readability. Tests must stay passing. Lint modified files.

---

## Error Handling

- **GREEN phase failures**: Retry 3x → invoke `systematic-debugging` for root cause analysis
- **Lint failures**: Attempt fix → continue with warning if unfixable
- **Unrecoverable issues**: Log in context, mark subtask failed, continue to next

---

## Completion Criteria

- All waves executed, all subtasks processed
- Integration checks passed after each wave
- Final verification: all tests pass, lint clean
- Cross-wave code review passed
- Adversarial review passed (zero HIGH findings or user-accepted)
- Session context updated with final status
