---
name: context-file-management
description: Use when working with multi-agent workflows or complex tasks requiring session tracking - manages session context files for state persistence, agent coordination, and workflow traceability across task execution
---

# Context File Management

## Overview

Session context files enable state persistence and agent coordination in multi-agent workflows. They track objectives, technical decisions, activity logs, and current state throughout task execution.

**Core principle:** One session context file per workflow, updated throughout execution, shared across all agents.

## When to Use

Use context files when:
- Executing multi-step workflows (planning, implementation, review)
- Coordinating multiple agents on same task
- Need traceability of decisions and actions
- Task spans multiple sessions or tool invocations
- Agents need shared state without re-reading entire conversation

**Don't use when:**
- Single, simple operations (file read, quick fix)
- No agent coordination needed
- Conversation context is sufficient

## Context File Types

### 1. Session Context File

**Purpose:** Track workflow state and execution progress

**Location:** `tasks/session_context_<session_id>.md`

**Contains:**
- Meta information (workflow type, session ID, timestamps)
- Objective and task description
- Current state (which phase/step)
- Technical decisions made
- Activity log with timestamps
- Blockers and issues
- Quality gates checklist

**When to create:** Start of any multi-step workflow

### 2. Task Documentation File

**Purpose:** Structured task breakdown and implementation plan

**Location:** `tasks/<descriptive-name>_<session_id>.md`

**Contains:**
- Task objective
- Subtask breakdown
- Implementation steps
- Success criteria
- Links to existing code patterns
- Acceptance criteria

**When to create:** During planning workflows (plan-task)

## Session ID Generation

**Pattern:** `<workflow>_$(date +%Y%m%d_%H%M%S)_$RANDOM`

**Examples:**
- `plan_20251122_143022_12345`
- `implement_20251122_150530_98765`
- `issue_20251122_153045_44444`

**Why this format:**
- `<workflow>`: Identifies workflow type
- `YYYYMMDD_HHMMSS`: Sortable timestamp
- `$RANDOM`: Prevents collisions in same second

## Context File Lifecycle

### 1. Creation (Workflow Start)

```markdown
# Session Context: <Workflow Name>

## Meta Information
- **Session ID:** <session_id>
- **Workflow Type:** <planning/implementation/review>
- **Created:** <ISO timestamp>
- **Status:** In Progress

## Objective
<Clear statement of what this session aims to accomplish>

## Current State
Initial state: Starting <workflow phase>

## Technical Decisions
<Empty initially - populated as decisions are made>

## Activity Log
- [<timestamp>] Session initialized
- [<timestamp>] Created context file

## Blockers
<None initially>

## Quality Gates
- [ ] <Workflow-specific checklist items>
```

### 2. Updates (Throughout Execution)

**CRITICAL:** Update context at these key points:

**After major state changes:**
```markdown
## Current State
RED phase for subtask 1: Writing failing tests
```

**After technical decisions:**
```markdown
## Technical Decisions
- Chose JWT over session-based auth for stateless microservices
- Using 15-min token expiry with refresh tokens
```

**After significant actions:**
```markdown
## Activity Log
- [2025-11-22 14:30] Created test file: src/auth/auth.spec.ts
- [2025-11-22 14:35] Tests written (3 new tests, all failing as expected)
- [2025-11-22 14:42] Implementation complete (tests passing: 3/3)
```

**When blockers occur:**
```markdown
## Blockers
- Test failure in auth.spec.ts: Expected 3 results, got 0
  - Attempt 1/3: Investigating token generation logic
  - Resolution: Fixed async timing issue, tests now pass
```

### 3. Completion (Workflow End)

```markdown
## Meta Information
- **Status:** Completed

## Current State
Final state: All subtasks complete, quality gates passed

## Quality Gates
- [x] All tests passing (24/24)
- [x] Linting clean
- [x] All subtasks completed
- [x] Documentation updated
```

## Passing Context to Agents

### Method 1: Context File Reference (Recommended)

**Start every agent prompt with context file path:**

```
Context file: tasks/session_context_plan_20251122_143022_12345.md

[Task instructions for agent]
```

**Agent responsibilities:**
1. Read context file at start
2. Extract relevant information (objective, technical decisions, etc.)
3. Update context file sections on completion
4. Log significant actions in Activity Log

### Method 2: Inline Context (For Small Contexts)

Only when context is < 100 words and won't be reused:

```
Background: Implementing OAuth2 authentication with JWT tokens.
Technical constraint: Must support GitHub and Google providers.

[Task instructions]
```

## Update Patterns

### Pattern 1: State Transition Updates

**When:** After completing a phase or step

```markdown
## Current State
~~Implementing subtask 1/5: Create User model~~
Implementing subtask 2/5: Add OAuth endpoints
```

**Or using Edit tool:**
```
old_string: "Current State\nImplementing subtask 1/5: Create User model"
new_string: "Current State\nImplementing subtask 2/5: Add OAuth endpoints"
```

### Pattern 2: Incremental Log Updates

**When:** After significant actions

```markdown
## Activity Log
- [2025-11-22 14:30] Session initialized
- [2025-11-22 14:35] Created task documentation file
- [2025-11-22 14:40] Queried memory for OAuth patterns
- [2025-11-22 14:45] Found 3 relevant past implementations
```

### Pattern 3: Decision Documentation

**When:** Making architectural or technical choices

```markdown
## Technical Decisions

### Authentication Strategy
- **Decision:** JWT tokens instead of sessions
- **Reason:** Stateless auth for microservices architecture
- **Trade-off:** Cannot revoke tokens immediately
- **Mitigation:** Short token expiry (15min) with refresh tokens
- **Date:** 2025-11-22
```

### Pattern 4: Blocker Tracking

**When:** Encountering issues or failures

```markdown
## Blockers

### Test Failures in auth.spec.ts
- **Symptom:** Expected 3 results, got 0
- **Attempts:**
  - Attempt 1/3: Investigating token generation logic
  - Attempt 2/3: Fixed async timing issue
  - Attempt 3/3: Tests now pass (3/3)
- **Resolution:** Added await for async token generation
- **Status:** Resolved
```

## Multi-Agent Coordination

### Sequential Agent Pattern

**Scenario:** Agents execute one after another

```
1. Planning Agent:
   - Creates: session_context_<id>.md
   - Updates: Objective, Technical Decisions
   - Passes: Context file path to next agent

2. Implementation Agent:
   - Reads: session_context_<id>.md
   - Updates: Current State, Activity Log, Blockers
   - Passes: Context file path to next agent

3. Review Agent:
   - Reads: session_context_<id>.md
   - Updates: Quality Gates, Final State
   - Marks: Status as "Completed"
```

### Parallel Agent Pattern

**Scenario:** Independent agents working on separate tasks

```
1. Coordinator Agent:
   - Creates: session_context_main_<id>.md
   - Creates: session_context_task1_<id>.md
   - Creates: session_context_task2_<id>.md

2. Task Agents (parallel):
   - Agent 1: Works with session_context_task1_<id>.md
   - Agent 2: Works with session_context_task2_<id>.md

3. Coordinator Agent:
   - Reads: Both task context files
   - Synthesizes: Results into main context
   - Updates: session_context_main_<id>.md with summary
```

## File Organization

### Directory Structure

```
tasks/
├── session_context_plan_20251122_143022_12345.md
├── user_authentication_oauth2_20251122_143022_12345.md
├── session_context_implement_20251122_150530_98765.md
└── session_context_review_20251122_160100_11111.md
```

### Naming Conventions

**Session context files:**
- Pattern: `session_context_<workflow>_<timestamp>_<random>.md`
- Example: `session_context_plan_20251122_143022_12345.md`

**Task documentation files:**
- Pattern: `<descriptive-name>_<timestamp>_<random>.md`
- Example: `user_authentication_oauth2_20251122_143022_12345.md`

**Link between files:**
```markdown
# Session Context: Planning User Authentication

Related files:
- Task documentation: tasks/user_authentication_oauth2_20251122_143022_12345.md
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Creating multiple context files for same workflow | Use one session context, update throughout |
| Not updating context after decisions | Update immediately when decisions made |
| Vague activity log entries | Include timestamps, file paths, specific actions |
| Missing context file path in agent prompts | Always start agent prompts with "Context file: path" |
| Not reading context before starting | Agents must read context to understand workflow state |
| Relative paths in context files | Always use absolute paths for reliability |

## Integration with Commands

### plan-task Command

**Creates:**
- `session_context_plan_<timestamp>_<random>.md`
- `<descriptive-name>_<timestamp>_<random>.md`

**Updates:**
- Current State: "Planning completed - [summary]"
- Technical Decisions: Architectural choices from analysis
- Activity Log: Codebase discovery, memory queries, planning steps

### implement-plan Command

**Creates:**
- `session_context_implement_<timestamp>_<random>.md`

**Updates:**
- Current State: After each TDD phase (RED/GREEN/REFACTOR)
- Technical Decisions: Implementation choices, refactoring rationale
- TDD Cycle Tracking: Test counts, pass/fail results
- Activity Log: Implementation actions with timestamps
- Blockers: Test failures, resolution attempts

### Agent Coordination (Custom Workflows)

**Pattern:**
```
Main Agent:
1. Create session context file
2. Initialize with objective and workflow type
3. Pass context file path to specialized agent

Specialized Agent:
1. Read context file (extract objective, decisions, constraints)
2. Execute specialized task
3. Update context file (log actions, decisions, results)
4. Return control to main agent

Main Agent:
1. Read updated context file
2. Proceed with next step
```

## Quality Standards

**Context file should always:**
- Have unique session ID
- Use absolute paths for file references
- Include timestamps in ISO format or readable format
- Document WHY decisions were made, not just WHAT
- Track complete activity history
- Maintain current state accuracy

**Activity log entries should include:**
- Timestamp
- Action description
- File paths (absolute)
- Results or outcomes
- Any blockers encountered

**Technical decisions should include:**
- What was decided
- Why (reasoning)
- Trade-offs acknowledged
- Alternatives considered (if any)
- Date of decision

## Real-World Impact

**With context files:**
- Agents understand workflow state without re-reading entire conversation
- Decisions are documented for future reference
- Debugging is faster (complete activity log)
- Multiple agents can coordinate effectively
- Workflow progress is visible and trackable

**Without context files:**
- Agents duplicate work (no shared state)
- Decisions are lost in conversation history
- Debugging requires re-reading entire conversation
- Agent coordination is difficult
- No traceability of actions

## Quick Reference

### Context File Creation Checklist

- [ ] Generate unique session ID
- [ ] Create session_context_<session_id>.md
- [ ] Initialize meta information section
- [ ] Set objective clearly
- [ ] Set initial current state
- [ ] Include empty sections for decisions, logs, blockers

### Context Update Checklist

- [ ] Update current state after phase transitions
- [ ] Log significant actions with timestamps
- [ ] Document technical decisions with rationale
- [ ] Track blockers with resolution attempts
- [ ] Use Edit tool for updates (preserve structure)

### Agent Prompt Checklist

- [ ] Start with "Context file: <absolute_path>"
- [ ] Specify which sections agent should update
- [ ] Clarify agent's responsibilities
- [ ] Request summary of actions taken

## Related Skills

- **subagent-driven-development** - Uses context files for task execution
- **persistent-context** - Long-term memory (MCP), complements session context
- **agent-coordination** - Orchestrating multiple agents with context files
