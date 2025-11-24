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

## Agent Routing

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

1. **Create session context file**:
   ```bash
   session_id="<workflow>_$(date +%Y%m%d_%H%M%S)_$RANDOM"
   # Create: tasks/session_context_${session_id}.md
   ```

2. **Initialize with**:
   - Objective and workflow type
   - Current state
   - Technical decisions
   - Activity log

3. **Pass to agents**: Start every agent prompt with context file path

4. **Agents must**:
   - Read context on start
   - Update relevant sections during work
   - Log significant actions
   - Return summary

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
