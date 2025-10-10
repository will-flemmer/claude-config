# plan-task

Intelligently plan and decompose user-provided tasks into structured, actionable subtasks with comprehensive context sharing for multi-agent workflows.

**IMPORTANT**: This command creates structured task plans with session context files to enable coordinated multi-agent execution. Always use the task-decomposition-expert agent for complex task breakdown.

**VERY IMPORTANT**: The templates and configuration can be found in the `~/.claude/commands/plan-task` folder.

## Usage

```bash
plan-task [OPTIONS] <task_description>
plan-task [OPTIONS] --interactive
```

### Pre-Planning Clarification

Before creating the task plan, the command will ask intelligent clarifying questions when the task description is vague or incomplete (e.g., descriptions under 20 words, missing key technical terms, or containing uncertain words like "maybe", "probably", "some", "few"):

1. **Scope**: What are the boundaries and specific deliverables of this task?
2. **Dependencies**: What existing code, systems, or components does this interact with?
3. **Technical Constraints**: Are there specific technologies, patterns, frameworks, or limitations to follow?
4. **Success Criteria**: How will we know this task is complete? What are the measurable outcomes?
5. **Priority/Urgency**: What's the timeline, importance, or blocking factors?

The command uses these answers to enrich the task context before routing to the task-decomposition-expert agent.

## Options

- `-h, --help`: Show detailed help message with examples
- `-i, --interactive`: Interactive mode for complex task planning with detailed requirements gathering
- `--session-id <id>`: Use a specific session ID (default: auto-generated)

## Multi-Agent Workflow with Context Sharing

**MANDATORY**: This command MUST create a session context file and route task decomposition through the specialized task-decomposition-expert agent. Never attempt task breakdown directly.

### Context File Creation

**CRITICAL**: Before starting the agent workflow:
1. Generate unique session ID using pattern: `plan_$(date +%Y%m%d_%H%M%S)_$RANDOM`
2. Create session context file at: `tasks/session_context_<session_id>.md`
3. Create task documentation file at: `tasks/<descriptive-name>_<session_id>.md`
4. Pass context file path to ALL agents in their prompts

The command enforces a single agent phase with shared context:

1. **PHASE 1 - Task-Decomposition-Expert**: Analyzes task complexity, asks follow-up questions if needed, breaks down into actionable subtasks, and updates both context and task documentation files

### Agent Coordination Flow with Context

```
Create Session Context File →
  User Input + Clarification Q&A →
  PHASE 1: Task-Decomposition-Expert (complexity analysis, task breakdown, implementation steps) → Update Context & Task Doc →
  Task Plan Files Ready
```

**CRITICAL**: The task-decomposition-expert agent must complete its analysis and update both the session context file and task documentation file before proceeding.

## Task File Structure

The command generates two interconnected files:

### 1. Session Context File (`tasks/session_context_<session_id>.md`)
Tracks the workflow state and agent activity:
- Objective and workflow type
- Current state
- Clarifications and Q&A
- Discovered context sections
- Agent activity log

### 2. Task Documentation File (`tasks/<descriptive-name>_<session_id>.md`)
Contains the actual task breakdown and plan:
- Task objective and description
- Task breakdown and subtasks
- Implementation steps
- Success criteria
- Links to session context

## Examples

### Basic Usage

```bash
# Simple task with clear description
plan-task "Implement user authentication with OAuth2 support for GitHub and Google providers"

# Expected:
# 1. Creates session context file
# 2. Routes to task-decomposition-expert
# 3. Generates structured task plan with subtasks
# Output: Task plan created at tasks/user_authentication_oauth2_20251010_143022_12345.md
```

### Interactive Mode

```bash
# Complex task needing detailed clarification
plan-task --interactive "Build a notification system"

# Expected:
# - Asks clarifying questions about scope, dependencies, technical constraints
# - Creates enriched session context with Q&A
# - Routes to task-decomposition-expert with full context
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
# - Routes to task-decomposition-expert
# - Generates detailed task plan
```

### Agent Workflow (Internal)

```bash
# The command internally uses this workflow:

# 1. Analyze task description for clarity
# 2. Ask clarifying questions if needed
# 3. Generate unique session ID
# 4. Create session context file with Q&A
# 5. Create task documentation file (initial structure)
# 6. Route to task-decomposition-expert with context file path
# 7. Agent updates both files with analysis and breakdown
# 8. Return file paths
```

## Features

### Intelligent Clarification

- **Vagueness Detection**: Automatically identifies unclear task descriptions
- **Contextual Questions**: Asks relevant questions based on missing information
- **Enriched Context**: Incorporates answers into session context for agent use

### Automatic Session Management

- **Unique Session IDs**: Generates collision-free identifiers using timestamp and random component
- **Context Tracking**: Links all related files and agent activities
- **Workflow State**: Maintains current state and progress through workflow phases

### Task Complexity Analysis

- **Scope Assessment**: Uses task-decomposition-expert to evaluate task complexity
- **Subtask Generation**: Breaks down complex tasks into manageable components
- **Implementation Guidance**: Provides step-by-step implementation approach

### Multi-Agent Integration

- **Orchestrated Workflow**: Seamless routing to task-decomposition-expert agent
- **Context Sharing**: Agents read and update shared context files
- **Extensible Design**: Other commands can use generated plans as input

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
- **jq**: JSON processing for configuration and agent communication
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
- **Agent failures**: Graceful error reporting with retry suggestions

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

### Agent Integration

#### Required Agents

- **task-decomposition-expert**: Task complexity analysis, requirement structuring, subtask breakdown, implementation planning

#### Agent Capabilities Required

- **Context Management**: Must read and update shared context files
- **Task Analysis**: Must evaluate complexity and break down into subtasks
- **Documentation**: Must update both session context and task documentation files
- **Error Handling**: Robust error reporting and recovery mechanisms

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
- **Agent traceability**: Complete log of agent activities in session context
- **Actionable subtasks**: Each subtask is concrete and implementable

## Agent-First Execution Requirements

**MANDATORY**: This command MUST follow Agent-First Task Execution guidelines from CLAUDE.md:

### Required Agent Routing

1. **NEVER perform task decomposition directly** - always route through task-decomposition-expert agent
2. **Context file creation** - always create session context file before agent invocation
3. **Context sharing** - agent reads and updates the shared context file
4. **Agent specialization** - task-decomposition-expert handles all complexity analysis and breakdown

### Compliance Verification

Before using this command, verify:
- [ ] Session context file is created first
- [ ] Task documentation file is initialized
- [ ] task-decomposition-expert agent is invoked with context file path in prompt
- [ ] Agent updates both session context and task documentation
- [ ] No direct task breakdown bypasses the agent workflow

### Enforcement Mechanisms

- Command documentation mandates agent usage at every step
- Examples show only proper Task() tool routing to task-decomposition-expert
- Interactive mode requires agent phase completion
- All usage patterns demonstrate proper context sharing with absolute file paths

This command exemplifies best practices in Agent-First task planning while delivering practical value for breaking down complex work into manageable, actionable components.
