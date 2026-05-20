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

## Git

- **Never** add `Co-Authored-By` trailers to commits. No co-author lines, ever.

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

<!-- code-review-graph MCP tools -->
## MCP Tools: code-review-graph

**IMPORTANT: This project has a knowledge graph. ALWAYS use the
code-review-graph MCP tools BEFORE using Grep/Glob/Read to explore
the codebase.** The graph is faster, cheaper (fewer tokens), and gives
you structural context (callers, dependents, test coverage) that file
scanning cannot.

### When to use graph tools FIRST

- **Exploring code**: `semantic_search_nodes` or `query_graph` instead of Grep
- **Understanding impact**: `get_impact_radius` instead of manually tracing imports
- **Code review**: `detect_changes` + `get_review_context` instead of reading entire files
- **Finding relationships**: `query_graph` with callers_of/callees_of/imports_of/tests_for
- **Architecture questions**: `get_architecture_overview` + `list_communities`

Fall back to Grep/Glob/Read **only** when the graph doesn't cover what you need.

### Key Tools

| Tool | Use when |
| ------ | ---------- |
| `detect_changes` | Reviewing code changes — gives risk-scored analysis |
| `get_review_context` | Need source snippets for review — token-efficient |
| `get_impact_radius` | Understanding blast radius of a change |
| `get_affected_flows` | Finding which execution paths are impacted |
| `query_graph` | Tracing callers, callees, imports, tests, dependencies |
| `semantic_search_nodes` | Finding functions/classes by name or keyword |
| `get_architecture_overview` | Understanding high-level codebase structure |
| `refactor_tool` | Planning renames, finding dead code |

### Workflow

1. The graph auto-updates on file changes (via hooks).
2. Use `detect_changes` for code review.
3. Use `get_affected_flows` to understand impact.
4. Use `query_graph` pattern="tests_for" to check coverage.
