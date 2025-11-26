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

## Skills

| Situation | Skill |
|-----------|-------|
| First substantial request | `query-decision` |
| Planning features/architecture | `memory-driven-planning` |
| Working with unit tests | `unit-testing` |
| Reading/searching 2+ locations | `parallel-execution-patterns` |
| Before claiming work complete | `verification-before-completion` |

**Skills don't auto-run. Invoke explicitly when applicable.**

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

## Required Tools

- `git`, `gh` - Version control and GitHub CLI
- `just` - Command runner (test, lint, build)
- `jq` - JSON processing
