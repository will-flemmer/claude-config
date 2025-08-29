# create-gh-issue

Transform user task descriptions into well-structured GitHub issues through coordinated multi-agent workflow orchestration.

**IMPORTANT**: Always use the provided scripts from `~/.claude/commands/create-gh-issue` folder. This command leverages multiple specialized agents for optimal issue quality.

**VERY IMPORTANT**: The scripts can be found in the `~/.claude/commands/create-gh-issue` folder.

## Usage

```bash
create-gh-issue [OPTIONS] <task_description>
create-gh-issue [OPTIONS] --interactive
```

### Pre-Creation Questions

Before creating the issue, the command will ask clarifying questions to ensure the issue is complete and well-structured:

1. **Task Type**: Confirm if it's a task, story, or project
2. **Acceptance Criteria**: Gather specific success metrics if not provided
3. **Technical Context**: Ask about implementation preferences or constraints
4. **Dependencies**: Identify any blocking issues or prerequisites

The command uses these answers to enhance the issue quality before routing to agents.

## Options

- `-h, --help`: Show detailed help message with examples
- `-i, --interactive`: Interactive mode for complex requirements gathering
- `--milestone <milestone>`: Milestone to assign to the issue

## Multi-Agent Workflow with Context Sharing

**MANDATORY**: This command MUST create a session context file and route through specialized agents sequentially. Never create issues directly.

### Context File Creation
**CRITICAL**: Before starting the agent workflow:
1. Use simple context file naming: `tasks/create_issue.md`
2. Create context file with task description and requirements
3. Pass context file path to ALL agents in their prompts

The command enforces two sequential agent phases with shared context:

1. **PHASE 1 - Task-Decomposition-Expert**: Analyzes complexity, determines optimal template, and structures requirements (updates context)
2. **PHASE 2 - Issue-Writer**: Creates the final GitHub issue with proper structure (reads/updates context)

### Agent Coordination Flow with Context
```
Create Context File →
  User Input → 
  PHASE 1: Task-Decomposition-Expert (complexity analysis, requirements structuring) → Update Context →
  PHASE 2: Issue-Writer (GitHub issue creation with structure) → Update Context →
  Issue URL Response
```

**CRITICAL**: All phases must complete before proceeding. Each agent reads the shared context file and updates it with their findings.

## Issue Templates

The command automatically detects the appropriate template based on task complexity:
- **Simple tasks**: Single, specific actionable items
- **Complex features**: Multiple related tasks or feature development
- **Large projects**: Multiple stories/features requiring milestone breakdown

## Examples

### Basic Usage
```bash
# Simple task
create-gh-issue "Add search functionality to the user dashboard"

# Expected: 
# 1. Asks clarifying questions about search requirements
# 2. Creates issue with clear acceptance criteria
# Output: Issue #123 created at https://github.com/owner/repo/issues/123
```

### Interactive Mode
```bash
# Complex feature needing detailed requirements
create-gh-issue --interactive "Build user notification system"

# Expected:
# - Asks about notification types, delivery methods, etc.
# - Shows preview before creation
# - Creates comprehensive issue
```

### Agent Workflow (Internal)
```bash
# The command internally uses this workflow:

# 1. Ask clarifying questions
# 2. Create context file with answers
# 3. Route through task-decomposition-expert for analysis
# 4. Route through issue-writer for GitHub issue creation
# 5. Return issue URL
```


## Features

### Automatic Repository Detection
- Creates GitHub issue in the current repository
- Detects current git repository using `gh repo view`
- Validates repository permissions before issue creation
- **MANDATORY**: Always prints the GitHub issue URL at the end of execution

### Intelligent Template Selection
- **Complexity Analysis**: Uses task-decomposition-expert to assess scope
- **Content Analysis**: Automatically determines appropriate structure

### Quality Validation
- **Title Optimization**: Ensures clear, actionable titles
- **Acceptance Criteria**: Generates specific, measurable criteria
- **Technical Notes**: Includes implementation guidance when relevant

### Multi-Agent Coordination
- **Orchestrated Workflow**: Seamless hand-off between specialized agents
- **Context Sharing**: Agents share information via context files

## Interactive Mode Flow

**MANDATORY AGENT WORKFLOW**: When using `--interactive` flag or when questions are needed, must route through both agents:

1. **Initial Questions**: Ask clarifying questions upfront to gather all necessary information:
   - What type of issue is this? (task/story/project)
   - What are the specific acceptance criteria?
   - Are there any technical constraints or preferences?
   - Are there any dependencies or blocking issues?
2. **PHASE 1 - Task-Decomposition-Expert**: Analyzes enriched input with answers, structures complete requirements
3. **Preview Generation**: Shows structured requirements preview for user review
4. **User Confirmation**: User confirms before proceeding to creation
5. **PHASE 2 - Issue-Writer**: Creates final GitHub issue in current repository with structured requirements
6. **Result**: Returns issue URL and success confirmation - **MANDATORY** URL output

**CRITICAL**: Always gather necessary information through questions BEFORE starting agent phases. This ensures agents have complete context for optimal issue creation.

## Output Formats

### Human-Readable Output
```
✅ GitHub Issue Created Successfully in Current Repository

Title: Add dark mode toggle to user settings
Issue: #123
URL: https://github.com/owner/repo/issues/123
Template: task

📋 Issue Summary:
- Clear acceptance criteria defined
- Implementation notes included
- Ready for development

🔗 Issue URL: https://github.com/owner/repo/issues/123
```


## Requirements

### System Dependencies
- **GitHub CLI** (`gh`): Must be installed and authenticated (`gh auth login`)
- **Git**: For repository detection and context
- **jq**: JSON processing for agent communication
- **curl**: HTTP requests for API fallbacks

### Permissions
- **Repository Access**: Read/write access to target repository
- **Issue Creation**: Permission to create issues in target repository
- **API Limits**: Respects GitHub API rate limiting

### Environment
- Must be run from within a git repository (unless `--repo` specified)
- GitHub CLI must be authenticated with appropriate permissions
- Network connectivity required for agent coordination and GitHub API

## Error Handling

- **Not in git repository**: Clear message to navigate to a git repository
- **Insufficient permissions**: Checks issue creation permissions
- **Empty descriptions**: Prompts for meaningful task descriptions
- **GitHub CLI not authenticated**: Instructions to run `gh auth login`

## Implementation

### File Structure
```
commands/create-gh-issue/
├── create-gh-issue.sh          # Main command script with agent orchestration
├── lib/
│   ├── template-detector.sh    # Template selection and validation logic
│   ├── repo-utils.sh          # Repository detection and validation
│   ├── output-formatter.sh    # Human and JSON output formatting
│   └── agent-coordinator.sh   # Multi-agent workflow coordination
├── config.json                # Default configuration and templates
└── templates/
    ├── task-template.md       # Task issue template structure
    ├── story-template.md      # Story issue template structure
    └── project-template.md    # Project issue template structure
```

### Agent Integration

#### Required Agents
- **task-decomposition-expert**: Task complexity analysis, requirements structuring, template recommendation
- **issue-writer**: GitHub issue creation with proper formatting and structure

#### Agent Capabilities Required
- **Context Management**: All agents must read and update shared context files
- **GitHub Integration**: issue-writer must support `gh` CLI for issue creation
- **Error Handling**: Robust error reporting and recovery mechanisms



## Troubleshooting

### Common Issues

#### "Repository not found"
```bash
# Verify you're in a git repository
git status
```

#### "GitHub CLI not authenticated"
```bash
# Authenticate with GitHub
gh auth login
```

## Quality Standards

### Quality Standards
- **Title clarity**: Clear, actionable titles
- **Acceptance criteria**: Specific, measurable criteria
- **Technical guidance**: Implementation notes when applicable
- **Error recovery**: Graceful handling of failures
- **Input validation**: Validation with helpful error messages

## Agent-First Execution Requirements

**MANDATORY**: This command MUST follow Agent-First Task Execution guidelines from CLAUDE.md:

### Required Agent Routing
1. **NEVER create issues directly** - always use the two-phase agent workflow
2. **Sequential execution** - each phase must complete before the next begins
3. **Context sharing** - each agent reads and updates the shared context file
4. **Agent specialization** - each agent handles their domain expertise only

### Compliance Verification
Before using this command, verify:
- [ ] Task-decomposition-expert analyzes complexity, structures requirements, and determines template
- [ ] Issue-writer creates the final GitHub issue with proper structure
- [ ] Both phases complete successfully before reporting completion
- [ ] Context file is created and shared between agents
- [ ] No direct issue creation bypasses the agent workflow

### Enforcement Mechanisms
- Command documentation mandates agent usage at every step
- Examples show only proper Task() tool routing to agents
- Interactive mode requires both agent phases
- All usage patterns demonstrate sequential agent coordination with context sharing

This command exemplifies best practices in Agent-First multi-agent coordination while delivering practical value for GitHub issue management workflows.