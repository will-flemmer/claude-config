# Parallel Execution for plan-task and implement-plan

**Date**: 2026-02-19
**Status**: Approved

## Problem

Both `plan-task` and `implement-plan` execute work sequentially where parallelism is possible. `implement-plan` processes subtasks one at a time even when they have no dependencies. `plan-task` runs discovery phases sequentially when many are independent.

## Design

### 1. plan-task: Build Execution Waves

plan-task already decomposes tasks into subtasks with "Depends on" fields. Extend it to compute execution waves — groups of subtasks that can run in parallel.

**Changes:**

**A. Parallel Discovery Phase** — Combine codebase and API discovery into parallel bursts:

```
Parallel batch 1 (all at once):
  - Read README.md, ARCHITECTURE.md, package.json
  - Glob for services, lib, utils
  - Grep for exports
  - Grep for test patterns

Parallel batch 2 (depends on batch 1 results):
  - Read all discovered relevant source files in parallel
  - Dispatch Explore agent for API verification
```

**B. New Sequential Thinking Step** — Add wave computation between dependency analysis and risk identification:
- Group subtasks by dependency level (topological sort)
- Subtasks with no dependencies → Wave 1
- Subtasks depending only on Wave 1 → Wave 2
- And so on

**C. New Task Doc Section** — Add `## Execution Waves` after `## Task Breakdown`:

```markdown
## Execution Waves

### Wave 1 (no dependencies — run in parallel)
- Subtask 1: [Title]
- Subtask 3: [Title]

### Wave 2 (depends on Wave 1)
- Subtask 2: [Title] (depends on: Subtask 1)
- Subtask 4: [Title] (depends on: Subtask 3)

### Wave 3 (depends on Wave 2)
- Subtask 5: [Title] (depends on: Subtask 2, Subtask 4)
```

### 2. implement-plan: Wave-Based Parallel Dispatch

implement-plan reads the Execution Waves section and dispatches each wave as parallel subagents.

**Revised Flow:**

```
Read plan → Parse Execution Waves →
  For each wave:
    1. Dispatch all subtasks in wave as parallel Task subagents
    2. Wait for all subagents to complete
    3. Integration check:
       - Run tests for all files changed in this wave
       - Check for file conflicts between subagents
       - If conflicts: resolve before next wave
    4. Update session context with wave results
  → Final verification (full test + lint on all changed files)
```

**Subagent Prompt Structure:**
Each parallel subagent receives:
- Subtask title, description, acceptance criteria
- File paths and API references from the plan
- Instruction: "Follow RED -> GREEN -> REFACTOR strictly"
- Constraint: "Only modify files relevant to this subtask"
- Expected output: files changed, test results, summary

**Fallback:** If all subtasks are linearly dependent (single chain), execution degrades gracefully to sequential — no behavior change from today.

### 3. What Stays the Same

**plan-task:**
- Clarifying questions (need user input, inherently sequential)
- Sequential thinking analysis (each step builds on prior)
- Context file creation and tracking

**implement-plan:**
- Session context tracking throughout
- Full TDD methodology per subtask (RED -> GREEN -> REFACTOR)
- Error handling (retry up to 3 times per subtask)
- Lint on changed files
- Final verification phase

## Files to Change

1. `commands/plan-task.md` — Add wave computation step, enforce parallel discovery
2. `commands/plan-task/templates/task_doc.md` — Add `## Execution Waves` section
3. `commands/implement-plan.md` — Replace sequential subtask loop with wave-based parallel dispatch
4. `commands/implement-plan/templates/session_context.md` — Add wave tracking section

## Risks

- **File conflicts**: Two parallel subagents edit the same file. Mitigated by dependency graph ensuring independent subtasks don't share files, plus integration check between waves.
- **Test interference**: Parallel test runs could interfere. Mitigated by each subagent running only its own related tests, with integration tests run between waves.
- **Graceful degradation**: Plans without explicit waves or with all-linear dependencies fall back to sequential execution.
