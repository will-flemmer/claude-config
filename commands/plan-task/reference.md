# plan-task Reference

Supplementary material for `plan-task`. The main execution procedure is in `commands/plan-task.md`.

## Context7: External Library Documentation

When the task involves external libraries and you need current API docs:

```javascript
// 1. Resolve library ID
mcp__context7__resolve-library-id({ libraryName: "prisma" })

// 2. Fetch docs
mcp__context7__get-library-docs({
  context7CompatibleLibraryID: "<resolved-id>",
  topic: "migrations",
  tokens: 5000
})
```

Skip if the task only involves internal code.

## Graph Tool Reference

| Tool | Use when |
|------|----------|
| `get_architecture_overview_tool` | First call — high-level structure, communities, coupling |
| `semantic_search_nodes_tool` | Find functions/classes by keyword or concept |
| `query_graph_tool` (file_summary) | List all nodes in a file |
| `query_graph_tool` (callers_of) | Who calls this function? |
| `query_graph_tool` (callees_of) | What does this function call? |
| `query_graph_tool` (imports_of) | What does this file import? |
| `query_graph_tool` (importers_of) | What files import this? |
| `query_graph_tool` (tests_for) | Find tests covering a module |
| `query_graph_tool` (children_of) | Nodes contained in a file/class |
| `query_graph_tool` (inheritors_of) | Classes inheriting from target |
| `list_communities_tool` | Module boundaries and groupings |
| `get_impact_radius_tool` | Blast radius of changes |
| `find_large_functions_tool` | Functions exceeding line-count threshold |

## Session ID Format

Pattern: `plan_YYYYMMDD_HHMMSS`
Source: today's date from `<env>` context + estimated time. No shell command needed.

Files created:
- `tasks/session_context_<session_id>.md`
- `tasks/<descriptive-name>_<session_id>.md`

## Clarification Question Categories

Ask 3-5 when triggered (task < 25 words, vague, missing constraints):

1. **Objective**: What problem? What outcome?
2. **Scope**: Included/excluded? Boundaries?
3. **Constraints**: Technologies? Performance? Integration points?
4. **Quality**: Testing? Documentation?
5. **Success**: How do we know it's done?

## Sequential Thinking Steps (Detail)

**Step 1 — Component Identification**: Logical components, functionality, boundaries.

**Step 2 — Decomposition**: Simplest breakdown, right-sized subtasks, independently testable.

**Step 3 — Complexity Assessment**:
- Simple: Single file, < 50 LOC, no dependencies
- Medium: Multiple files, < 200 LOC, few dependencies
- Complex: Many files, > 200 LOC, or intricate logic

**Step 4 — Dependency Analysis**: Order, parallelism, external deps, hidden deps, shared files.

**Step 4.5 — Execution Waves**:
- Topological sort by "Depends on" fields
- Wave 1: no dependencies (parallel)
- Wave N: depends only on prior waves
- File conflict check: same-wave subtasks can't modify same files
- Fallback: linear deps → single-subtask-per-wave

**Step 5 — Risk**: What could go wrong? Uncertain parts? Wrong estimates?

**Step 6 — Execution Order**: Optimal sequence, critical path, unblocking.

**Step 7 — Testing Strategy**: Per-subtask testing, patterns, integration needs.

**Step 8 — Final Review**: Complete? Clear criteria? Implementable? Revisions?

## Examples

### Basic Usage

```bash
plan-task "Implement user authentication with OAuth2 support for GitHub and Google providers"

# 1. Creates session context file
# 2. Runs get_architecture_overview + semantic_search_nodes("OAuth authentication") IN PARALLEL
# 3. Reads README.md, ARCHITECTURE.md IN PARALLEL
# 4. Uses query_graph(file_summary) to verify discovered APIs
# 5. Generates structured task plan
```

### Interactive Mode

```bash
plan-task --interactive "Build a notification system"

# - Asks clarifying questions about scope, dependencies, constraints
# - Creates enriched session context with Q&A
# - Runs graph discovery and reads docs IN PARALLEL
# - Generates comprehensive task breakdown
```

## Integration

**Consumed by**: `implement-plan`, `create-gh-issue`, `pr-checks`

**File paths**: All files relative to project root, NOT in ~/.claude/tasks/.

## Requirements

- **Git**: Repository detection
- **jq**: JSON processing
- tasks/ directory must exist or be creatable

## Troubleshooting

**"tasks/ directory not found"**: Run `mkdir -p tasks`

**"Session context file already exists"**: Use a different session ID or remove old file.

## Output Format

```
✅ Task Plan Created
Session: tasks/session_context_<id>.md
Plan: tasks/<name>_<id>.md
Subtasks: N | Complexity: X | Waves: Y
```
