# Development Guidelines

## Core Principles

### 1. Memory & Context
- **First request**: Query memory for relevant patterns, decisions, failures
- **Planning**: Use `memory-driven-planning` skill for architectural decisions
- **After completion**: Store learnings (patterns, bugs, optimizations) to memory

### 2. Parallel Execution
- **Always** execute 2+ independent operations in parallel (single message, multiple tool calls)
- **Examples**: Multiple file reads, multiple searches, parallel memory queries
- **Performance**: 5-8x faster than sequential execution

### 3. Verification
- **Never** claim work is complete/fixed/passing without running verification command
- **Evidence before assertions** - show actual test output, build results, lint status
- **No exceptions** - this is non-negotiable

### 4. Test-Driven Development
- **RED** → Write failing test
- **GREEN** → Implement minimal code to pass
- **REFACTOR** → Improve code quality
- Use `unit-testing` skill when working with tests

## Skills (Manual Invocation)

Invoke skills when the specific situation applies:

| Situation | Skill | When to Use |
|-----------|-------|-------------|
| Planning features or architecture | `memory-driven-planning` | Before designing significant changes |
| Working with unit tests | `unit-testing` | Reading, writing, updating, or planning tests |
| Implementing planned tasks | `subagent-driven-development` | Multi-step implementations with subtasks |
| Coordinating multiple agents | `agent-coordination` | Complex workflows needing specialized agents |
| Domain: Stripe integration | `stripe` | Payment processing, subscriptions, webhooks |

5. **Working with unit tests in any way?** (reading, writing, updating, planning, evaluating, reviewing)
   - ✅ YES → Invoke `Skill({ skill: "unit-testing" })`

**REMEMBER:** Skills don't auto-run. You must explicitly invoke them!

---

## Quick Reference

**3 Mandatory Skills:**
1. `query-decision` - First substantial request in session
2. `verification-before-completion` - Before claiming work complete
3. `parallel-execution-patterns` - Reading/searching 2+ locations

**Common Workflows:**
- Planning → `memory-driven-planning` skill
- Testing → `unit-testing` skill

## Skills Usage (MANDATORY)

**Skills are process automation tools that MUST be used proactively**. Skills orchestrate complex workflows that would otherwise require manual coordination.

### When to Use Skills (Use Aggressively)

| Trigger | Skill | Rationale |
|---------|-------|-----------|
| **EVERY first substantial request** | `query-decision` | Automatically decides if memory query needed |
| Reading 2+ files in parallel | `parallel-execution-patterns` | 5-8x performance boost |
| Multiple grep/glob operations | `parallel-execution-patterns` | Execute all searches simultaneously |
| Planning features/architecture | `memory-driven-planning` | Query memory for patterns, failures, decisions |
| About to claim work complete | `verification-before-completion` | ALWAYS verify before success claims |
| Working with unit tests (any capacity) | `unit-testing` | Apply TDD principles with proper coverage |
| Managing session context files | `context-file-management` | Track state across agents |

### Critical Skill Rules

1. **ALWAYS use `query-decision` on first substantial request** in a session
2. **ALWAYS use `verification-before-completion`** before claiming work is done
3. **ALWAYS use `parallel-execution-patterns`** when reading/searching 2+ locations
4. **ALWAYS use `memory-driven-planning`** when planning features
5. **ALWAYS use `unit-testing`** when working with unit tests in any capacity (reading, writing, planning, evaluating, reviewing)
6. **NEVER batch read/search operations** - use `parallel-execution-patterns` instead

### Skills vs Agents

- **Skills**: Process automation (how to work), invoked via `Skill` tool
- **Agents**: Domain expertise (what to do), invoked via `Task` tool
- **Use both**: Skills orchestrate agents for complex workflows

### Agent Routing

| Task Type | Agent | Context Required |
|-----------|-------|------------------|
| Code implementation | main Claude | Yes* |
| Code review | pr-reviewer | Yes* |
| PR management | pr-checker | Yes* |
| Issue creation | issue-writer | Yes* |
| Command creation | command-writer | No |
| Prompt optimization | prompt-engineer | Yes* |

*Context-sharing agents require session files: `tasks/session_context_<id>.md`

**Agent prompt format:**
```
Context file: tasks/session_context_<session_id>.md

[Task description and instructions]
```

## Context Sharing

**For multi-agent workflows:**

### Example 1: Feature Planning & Implementation
```
1. User: "Add user authentication with OAuth2"
2. Use `query-decision` skill (auto-decides memory query)
3. Use `memory-driven-planning` skill (queries past patterns/failures)
4. Create plan with context file
5. Implement following TDD methodology
6. Use `verification-before-completion` skill (verify before claiming done)
```

2. **Initialize with**:
   - Objective and workflow type
   - Current state
   - Technical decisions
   - Activity log

### Example 3: Writing Tests
```
1. User: "Add tests for the payment module"
2. Use `query-decision` skill (check memory for test patterns)
3. Use `unit-testing` skill (applies TDD principles)
4. Skill ensures focused coverage, edge cases, state changes
5. Use `verification-before-completion` (run tests before claiming done)
```

See `context-sharing-guide.md` for detailed protocol.

## Commands

- `/plan-task <description>` - Plan tasks with memory context
- `/implement-plan <file>` - TDD implementation with learning storage
- `/init-memory` - Initialize persistent memory system
- `/pr-checks [pr-url]` - Monitor and fix PR checks

## Quality Standards

- **TDD**: RED → GREEN → REFACTOR cycles
- **Simplicity**: Simplest solution that works
- **DRY**: No code duplication
- **Testing**: Aim for 100% critical path coverage
- **Linting**: Use `just lint` before committing

## Memory Format

When storing to memory, use temporal tracking:

```javascript
observations: [
  "Pattern: [description] [confidence: 0.8]",
  "Date: YYYY-MM-DD",
  "Status: Active",
  "Validated: N implementations [last: DATE]"
]
```

**Confidence levels:**
- 0.5 = Experimental
- 0.7 = Tested
- 0.9 = Proven in production
- 0.95 = Battle-tested

Update confidence and validation count when patterns are reused.

## Required Tools

- `git`, `gh` - Version control and GitHub CLI
- `just` - Command runner (test, lint, build)
- `jq` - JSON processing
