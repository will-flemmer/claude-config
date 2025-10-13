# plan-task

Intelligently plan and decompose user-provided tasks into structured, actionable subtasks with comprehensive context sharing.

**IMPORTANT**: This command is executed directly by the main Claude agent (not routed to a specialized agent). It creates structured task plans with session context files for implementation tracking.

**VERY IMPORTANT**: The templates and configuration can be found in the `~/.claude/commands/plan-task` folder.

## Usage

```bash
plan-task [OPTIONS] <task_description>
plan-task [OPTIONS] --interactive
```

## Parallel Execution Strategy

**CRITICAL PERFORMANCE OPTIMIZATION**: This command is designed for maximum parallelization to reduce execution time.

### Parallel Operations

Execute the following operations in parallel:

1. **Documentation Reading** (Parallel)
   - Send ONE message with MULTIPLE Read tool calls
   - Read simultaneously: README.md, ARCHITECTURE.md, CONTRIBUTING.md, AI_CONTRIBUTING.md, package.json
   - Time savings: 5 sequential reads (~15s) → 1 parallel batch (~3s) = **80% faster**

2. **Pattern Searching** (Parallel)
   - Send ONE message with MULTIPLE Grep/Glob tool calls
   - Search simultaneously for:
     * Similar test files (*.spec.ts, *.test.ts)
     * Similar implementations (components, services)
     * Design patterns (factories, builders, strategies)
     * Utility functions (helpers, utils)
     * Configuration files
   - Time savings: 5 sequential searches (~25s) → 1 parallel batch (~5s) = **80% faster**

### Example: Parallel Tool Usage

```typescript
// ❌ WRONG: Sequential execution (slow)
Read README.md
// wait for result...
Read ARCHITECTURE.md
// wait for result...
Grep for tests
// wait for result...
Grep for implementations
// Total time: ~40 seconds

// ✅ CORRECT: Parallel execution (fast)
// Single message with multiple tool calls:
Read README.md
Read ARCHITECTURE.md
Read CONTRIBUTING.md
Read AI_CONTRIBUTING.md
Grep pattern="test" type="ts"
Grep pattern="implementation" type="ts"
Grep pattern="factory" type="ts"
Glob pattern="**/*.spec.ts"
// Total time: ~5 seconds (8x faster!)
```

### Performance Impact

| Operation Type | Sequential | Parallel | Speedup |
|---------------|-----------|----------|---------|
| Read 5 docs | ~15s | ~3s | 5x faster |
| Search 5 patterns | ~25s | ~5s | 5x faster |
| **Total discovery** | **~40s** | **~8s** | **5x faster** |

### Pre-Planning Clarification

Before creating the task plan, the command will ask intelligent clarifying questions when the task description is vague or incomplete (e.g., descriptions under 20 words, missing key technical terms, or containing uncertain words like "maybe", "probably", "some", "few"):

1. **Scope**: What are the boundaries and specific deliverables of this task?
2. **Dependencies**: What existing code, systems, or components does this interact with?
3. **Technical Constraints**: Are there specific technologies, patterns, frameworks, or limitations to follow?
4. **Success Criteria**: How will we know this task is complete? What are the measurable outcomes?
5. **Priority/Urgency**: What's the timeline, importance, or blocking factors?

The command uses these answers to enrich the task context before starting the analysis.

## Options

- `-h, --help`: Show detailed help message with examples
- `-i, --interactive`: Interactive mode for complex task planning with detailed requirements gathering
- `--session-id <id>`: Use a specific session ID (default: auto-generated)

## Execution Workflow

**CRITICAL**: This command is executed directly by Claude. The workflow:

### Context File Creation

Before starting task analysis:
1. Generate unique session ID using pattern: `plan_$(date +%Y%m%d_%H%M%S)_$RANDOM`
2. Create session context file at: `tasks/session_context_<session_id>.md`
3. Create task documentation file at: `tasks/<descriptive-name>_<session_id>.md`

### Task Analysis Process

Claude will analyze the task directly by:
1. Asking follow-up clarification questions if needed
2. Reading codebase documentation IN PARALLEL (README, ARCHITECTURE, etc.)
3. Searching codebase IN PARALLEL for similar patterns and examples
4. Breaking down into actionable subtasks
5. Updating both context and task documentation files with pattern links

### Execution Flow with Parallel Operations

```
User Input + Clarification Q&A
  ↓
Create Session Context File
  ↓
Read Codebase Documentation IN PARALLEL ⚡
├─→ README.md
├─→ ARCHITECTURE.md
├─→ AI_CONTRIBUTING.md
└─→ Other docs
  ↓
Analyze Complexity & Extract Key Terms
  ↓
Search for Patterns IN PARALLEL ⚡
├─→ Similar tests (*.spec.ts, *.test.ts)
├─→ Similar implementations
├─→ Design patterns
└─→ Utility functions
  ↓
Generate Task Breakdown & Implementation Steps
  ↓
Update Context & Task Doc with Pattern Links
  ↓
Task Plan Files Ready ✅
```

**Note**: ⚡ indicates parallel execution for maximum performance

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

### Internal Execution Workflow

```bash
# The command uses this workflow:

# 1. Analyze task description for clarity
# 2. Ask clarifying questions if needed
# 3. Generate unique session ID
# 4. Create session context file with Q&A
# 5. Create task documentation file (initial structure)
# 6. Read codebase documentation IN PARALLEL (README, ARCHITECTURE, etc.)
#    - Uses multiple Read tool calls in single message for parallel execution
# 7. Search codebase for similar patterns IN PARALLEL
#    - Uses multiple Grep/Glob calls in single message
#    - Searches for tests, implementations, utilities simultaneously
# 8. Update both files with analysis, breakdown, and pattern links
# 9. Return file paths
```

## Features

### Intelligent Clarification

- **Vagueness Detection**: Automatically identifies unclear task descriptions
- **Contextual Questions**: Asks relevant questions based on missing information
- **Enriched Context**: Incorporates answers into session context for analysis

### Automatic Session Management

- **Unique Session IDs**: Generates collision-free identifiers using timestamp and random component
- **Context Tracking**: Links all related files and activities
- **Workflow State**: Maintains current state and progress through workflow phases

### Task Complexity Analysis

- **Scope Assessment**: Evaluates task complexity and effort estimates
- **Subtask Generation**: Breaks down complex tasks into manageable components
- **Implementation Guidance**: Provides step-by-step implementation approach

### Existing Code Pattern Discovery

- **Documentation-First Approach**: Reads codebase documentation (README, ARCHITECTURE, etc.) before searching
- **Structure-Aware Search**: Uses documentation knowledge to target appropriate directories
- **Similar Tests**: Automatically searches for and links to similar test files as examples
- **Similar Implementations**: Identifies related components, services, or modules
- **Design Patterns**: Links to existing code that uses relevant design patterns
- **Utility Functions**: Points to helper functions and utilities that may be useful
- **Context-Aware**: Uses codebase structure understanding to find relevant examples specific to the task

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


## Clarification Question Logic

The command uses the following heuristics to determine when clarification is needed:

### Triggers for Clarification

1. **Short descriptions**: Task descriptions under 20 words
2. **Vague language**: Contains words like "some", "few", "maybe", "probably", "might"
3. **Missing specifics**: No technical terms, frameworks, or concrete deliverables mentioned
4. **Scope ambiguity**: Multiple possible interpretations of the task

### Question Categories

Based on what's missing, the command asks:

- **Scope questions**: If boundaries or deliverables are unclear
- **Dependency questions**: If existing system integration is not specified
- **Technical questions**: If implementation approach or technologies are not mentioned
- **Success questions**: If completion criteria are not defined
- **Priority questions**: If urgency or timeline context is missing

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

1. **Context file creation** - always create session context file before starting analysis
2. **Parallel operations** - always use parallel tool calls for independent operations (documentation reading, pattern searches)
3. **Context updates** - update both session context and task documentation files with findings
4. **Pattern discovery** - include links to similar code patterns found in the codebase

### Compliance Checklist

When executing this command:
- [ ] Session context file is created first
- [ ] Task documentation file is initialized
- [ ] Documentation files are read IN PARALLEL (single message, multiple Read calls)
- [ ] Pattern searches are executed IN PARALLEL (single message, multiple Grep/Glob calls)
- [ ] Both session context and task documentation files are updated with findings
- [ ] Existing code patterns and examples are included in task documentation

This command delivers practical value for breaking down complex work into manageable, actionable components with maximum performance through parallel execution.
