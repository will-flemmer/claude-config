# Task: {{task_title}}

**Session ID**: {{session_id}} | **Created**: {{timestamp}} | **Status**: Planned

## Objective

{{task_description}}

## Verified Technical Foundation

**CRITICAL**: Every API suggested has been verified. No phantom APIs.

### APIs to USE (verified exists)

| API | Location | Signature |
|-----|----------|-----------|
| `[functionName]` | `path/to/file.ts:line` | `(params) => ReturnType` |

### APIs to CREATE (verified missing)

| API | Location | Signature | Subtask |
|-----|----------|-----------|---------|
| `[functionName]` | `path/to/file.ts` | `(params) => ReturnType` | Subtask N |

### BLOCKED (needs user input)

| Assumption | Blocker | Resolution |
|------------|---------|------------|
| [assumption] | [why blocked] | [action needed] |

## Task Breakdown

### Subtask 1: [Title]
- **What**: [description]
- **Depends on**: [prior subtasks or "none"]
- **Reference**: `path/to/similar.ts:line` (pattern to follow)
- **Tests**:
  - [ ] [test description - what behavior to verify]
  - [ ] [test description]
- **Done when**:
  - [ ] Tests pass
  - [ ] [additional acceptance criterion]

### Subtask 2: [Title]
- **What**: [description]
- **Depends on**: [prior subtasks or "none"]
- **Reference**: `path/to/similar.ts:line`
- **Tests**:
  - [ ] [test description]
- **Done when**:
  - [ ] Tests pass
  - [ ] [additional acceptance criterion]

## External Dependencies

- **[library/service]**: [what it's used for]

## Related Context

- **Session Context**: `{{session_context_path}}`
- **Working Directory**: `{{working_directory}}`
