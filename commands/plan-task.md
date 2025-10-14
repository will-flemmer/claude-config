# plan-task

**EXECUTION**: Main Claude agent (no routing)
**PURPOSE**: Analyze tasks and create actionable implementation plans

## What This Does
1. **Analyzes** requirements and existing codebase
2. **Breaks down** work into 3-7 subtasks with complexity estimates
3. **Identifies** dependencies and execution order
4. **Provides** implementation guidance and risk areas

## Key Features
- **Parallel execution** for 5-8x faster codebase analysis
- **Context integration** for multi-agent workflows
- **Complexity scoring** (Simple/Medium/Complex)
- **Dependency mapping** for optimal execution sequencing

**Configuration & Templates**: `~/.claude/commands/plan-task/`

## Usage

```bash
plan-task [OPTIONS] <task_description>
plan-task [OPTIONS] --interactive
```

## Parallel Execution Strategy

**CRITICAL**: Use parallel tool calls for 5-8x performance improvement.

### Pattern
Execute multiple tool calls in a single message for independent operations.

### When to Use
- **File discovery + reading**: Find files, then read relevant ones
- **Multi-file analysis**: Read related files simultaneously
- **Independent operations**: Any operations without dependencies

### Performance Example
```
Sequential:  5 files × 8 sec = 40 seconds
Parallel:    5 files in 1 call = 8 seconds (5x faster)
```

### Anti-Pattern (DO NOT DO)
Execute operations sequentially when they could be parallelized.

## Clarification Questions

**CRITICAL**: Always consider asking clarifying questions before starting analysis. Better to ask upfront than make wrong assumptions.

**When to Ask** (ask if ANY of these apply):
- Task description < 25 words
- Missing technical constraints or requirements
- Unclear boundaries or scope
- No mention of testing or quality requirements
- Integration points not specified
- Performance/scalability needs unclear
- Success criteria not defined
- ANY ambiguity about implementation approach

**Question Categories** (ask 3-5 targeted questions):
1. **Objective**: What problem are we solving? What's the desired outcome?
2. **Scope**: What's included/excluded? What's the boundary?
3. **Constraints**: Required technologies? Performance needs? Integration points?
4. **Quality**: Testing requirements? Documentation needs?
5. **Success**: How do we know when it's done? What are acceptance criteria?

**Default Behavior**: When in doubt, ASK. It's always better to clarify than to plan incorrectly.

The answers enrich the task context and ensure accurate planning.

## Options

- `-h, --help`: Show detailed help message with examples
- `-i, --interactive`: Interactive mode for complex task planning with detailed requirements gathering
- `--session-id <id>`: Use a specific session ID (default: auto-generated)

## Context Management

**MANDATORY**: Always create session context files for tracking.

**Context File Creation**:
1. Generate unique session ID: `plan_$(date +%Y%m%d_%H%M%S)_$RANDOM`
2. Create `tasks/session_context_<session_id>.md` immediately
3. Create `tasks/<descriptive-name>_<session_id>.md` for task plan

**Context Updates Required**:
1. **After codebase discovery**: Add discovered architecture to Technical Decisions
2. **After complexity analysis**: Update with findings and patterns
3. **Before completion**: Final summary with:
   - Current State: "Planning completed - [brief summary]"
   - Technical Decisions: Architecture choices, patterns
   - Activity Log: Complete analysis steps

## Execution Workflow

### 1. Context & Requirements Analysis
- **Create session context files** (session_context and task_doc)
- **Analyze task**: Extract objective, constraints, technologies
- **Ask clarifying questions**: 3-5 targeted questions (see Clarification Questions section)

### 2. Codebase Discovery (Use Parallel Execution)
**Find relevant files**:
```bash
find . -type f -name "*.ts" -o -name "*.js" | head -20
grep -r "pattern" --include="*.ts"
```

**Read key files in parallel** (single message with multiple Read calls):
- README.md, ARCHITECTURE.md, CONTRIBUTING.md, package.json

**Update context**: Add discovered architecture to `Technical Decisions`

### 3. Complexity Analysis & Task Breakdown
**Assess complexity** (Simple/Medium/Complex):
- Simple: Single file, < 50 LOC, no dependencies
- Medium: Multiple files, < 200 LOC, few dependencies
- Complex: Many files, > 200 LOC, or intricate logic

**Create tasks**: 3-7 subtasks, each with:
- Clear objective
- Acceptance criteria
- Estimated complexity
- Dependencies (if any)

### 4. Dependencies & Execution Order
**Identify**:
- Which tasks must complete first
- Which can run in parallel
- External dependencies (APIs, libraries)

**Recommend**: Optimal execution sequence

### 5. Implementation Notes & Context Update
**Provide**:
- Architecture decisions and rationale
- Testing strategy
- Risk areas requiring attention

**Update context before completion**:
```markdown
Current State: Planning completed - [brief summary]
Technical Decisions: [key architectural choices]
Activity Log: [add entry with findings]
```

## Task File Structure

The command generates two interconnected files:

### 1. Session Context File (`tasks/session_context_<session_id>.md`)
Tracks the workflow state and execution progress:
- Objective and workflow type
- Current state
- Clarifications and Q&A
- Discovered context sections
- Execution activity log

### 2. Task Documentation File (`tasks/<descriptive-name>_<session_id>.md`)
Contains the actual task breakdown and plan:
- Task objective and description
- Task breakdown and subtasks
- Implementation steps
- **Existing code patterns and examples** (similar tests, implementations, patterns)
- Success criteria
- Links to session context

## Examples

### Basic Usage

```bash
# Simple task with clear description
plan-task "Implement user authentication with OAuth2 support for GitHub and Google providers"

# Expected:
# 1. Creates session context file
# 2. Reads README.md, ARCHITECTURE.md, AI_CONTRIBUTING.md IN PARALLEL to understand project structure
# 3. Searches IN PARALLEL for similar authentication tests and OAuth patterns in codebase
# 4. Generates structured task plan with subtasks and pattern links
# Output: Task plan created at tasks/user_authentication_oauth2_20251010_143022_12345.md
#   - Includes links to similar test files (e.g., src/auth/auth.spec.ts)
#   - Includes links to existing OAuth implementations
#   - Includes links to authentication utilities
```

### Interactive Mode

```bash
# Complex task needing detailed clarification
plan-task --interactive "Build a notification system"

# Expected:
# - Asks clarifying questions about scope, dependencies, technical constraints
# - Creates enriched session context with Q&A
# - Reads documentation and searches patterns IN PARALLEL
# - Generates comprehensive task breakdown
```

### Vague Task with Auto-Clarification

```bash
# Incomplete/vague task description
plan-task "Add some search features"

# Expected:
# - Detects vague description (under 20 words, contains "some")
# - Automatically asks clarifying questions:
#   * What specific search features? (keyword search, filters, facets?)
#   * Where should search be added? (which pages/components?)
#   * What content should be searchable?
#   * Any performance or scalability requirements?
# - Creates enriched context with answers
# - Executes documentation reading and pattern searches IN PARALLEL
# - Generates detailed task plan
```

## Integration with Other Commands

### Consumed By

- **implement-gh-issue**: Can read task plans to implement structured work
- **create-gh-issue**: Can convert task plans into GitHub issues
- **pr-checks**: Can validate implementation against task success criteria

### File Paths

All generated files use absolute paths for reliability:
- Session context: `/Users/williamflemmer/Documents/claude-config/tasks/session_context_<session_id>.md`
- Task documentation: `/Users/williamflemmer/Documents/claude-config/tasks/<descriptive-name>_<session_id>.md`

## Output Formats

### Human-Readable Output

```
✅ Task Plan Created Successfully

Session ID: plan_20251010_143022_12345
Session Context: /Users/williamflemmer/Documents/claude-config/tasks/session_context_plan_20251010_143022_12345.md
Task Plan: /Users/williamflemmer/Documents/claude-config/tasks/user_authentication_oauth2_20251010_143022_12345.md

📋 Task Summary:
- Task complexity: Medium
- Subtasks identified: 5
- Implementation steps: 12
- Estimated effort: 3-5 days

🔗 Files:
- Session Context: tasks/session_context_plan_20251010_143022_12345.md
- Task Plan: tasks/user_authentication_oauth2_20251010_143022_12345.md
```

## Requirements

### System Dependencies

- **Git**: For repository detection and working directory context
- **jq**: JSON processing for configuration
- **date**: For timestamp generation in session IDs

### Permissions

- **File System Access**: Write access to tasks/ directory
- **Task Files**: Permission to create markdown files in tasks/ directory

### Environment

- Must be run from within a git repository (or specify working directory)
- tasks/ directory must exist or be creatable
- Network connectivity not required (local operation only)

## Error Handling

- **Empty task description**: Prompts for meaningful task description
- **Missing tasks/ directory**: Creates directory automatically
- **File write failures**: Clear error messages with permission checks
- **Execution failures**: Graceful error reporting with retry suggestions

## Implementation

### File Structure

```
commands/plan-task/
├── templates/
│   ├── session_context.md      # Session context file template
│   └── task_doc.md             # Task documentation template
├── lib/                        # (Reserved for future helper scripts)
└── config.json                 # Configuration for clarification questions and templates
```


## Troubleshooting

### Common Issues

#### "tasks/ directory not found"

```bash
# Create tasks directory
mkdir -p /Users/williamflemmer/Documents/claude-config/tasks
```

#### "Session context file already exists"

```bash
# Use a different session ID or remove old file
rm /Users/williamflemmer/Documents/claude-config/tasks/session_context_<old_id>.md
```

## Quality Standards

### Input Validation

- **Non-empty descriptions**: Task description must have meaningful content
- **Character limits**: Descriptions should be between 10-1000 characters
- **Clarity checks**: Automatically triggers clarification for vague inputs

### Output Quality

- **Structured format**: Session context and task docs follow consistent templates
- **Absolute paths**: All file references use full absolute paths
- **Activity tracking**: Complete log of analysis steps in session context
- **Actionable subtasks**: Each subtask is concrete and implementable

## Execution Requirements

**MANDATORY**: This command MUST follow these execution guidelines:

### Required Steps

1. **Clarifying questions** - ask 3-5 targeted questions if ANY triggers apply (see "When to Ask" section)
2. **Context file creation** - always create session context files before starting analysis
3. **Parallel operations** - always use parallel tool calls for independent operations (documentation reading, pattern searches)
4. **Context updates** - update both session context and task documentation files with findings
5. **Pattern discovery** - include links to similar code patterns found in the codebase

### Compliance Checklist

When executing this command:
- [ ] Clarifying questions asked if ANY "When to Ask" triggers apply
- [ ] Session context file is created with unique session ID
- [ ] Task documentation file is initialized
- [ ] Documentation files are read IN PARALLEL (single message, multiple Read calls)
- [ ] Pattern searches are executed IN PARALLEL (single message, multiple Grep/Glob calls)
- [ ] Both session context and task documentation files are updated with findings
- [ ] Existing code patterns and examples are included in task documentation

This command delivers practical value for breaking down complex work into manageable, actionable components with maximum performance through parallel execution.
