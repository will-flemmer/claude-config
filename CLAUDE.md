# Development Guidelines

## Core Principles

### 1. Parallel Execution
- **Always** execute 2+ independent operations in parallel (single message, multiple tool calls)
- **Examples**: Multiple file reads, multiple searches
- **Performance**: 5-8x faster than sequential execution

### 2. Verification
- **Never** claim work is complete/fixed/passing without running verification command
- **Evidence before assertions** - show actual test output, build results, lint status
- **No exceptions** - this is non-negotiable

### 3. Test-Driven Development
- **RED** → Write failing test
- **GREEN** → Implement minimal code to pass
- **REFACTOR** → Improve code quality
- Use `unit-testing` skill when working with tests

## Skills

| Situation | Skill |
|-----------|-------|
| Working with unit tests | `unit-testing` |
| Reading/searching 2+ locations | `parallel-execution-patterns` |
| Before claiming work complete | `verification-before-completion` |

**Skills don't auto-run. Invoke explicitly when applicable.**

## Commands

- `/plan-task <description>` - Plan tasks with codebase analysis
- `/implement-plan <file>` - TDD implementation
- `/pr-checks [pr-url]` - Monitor and fix PR checks

## Quality Standards

- **TDD**: RED → GREEN → REFACTOR cycles
- **Simplicity**: Simplest solution that works
- **DRY**: No code duplication
- **Testing**: Aim for 100% critical path coverage
- **Linting**: Use `just lint` before committing

## Required Tools

- `git`, `gh` - Version control and GitHub CLI
- `just` - Command runner (test, lint, build)
- `jq` - JSON processing
