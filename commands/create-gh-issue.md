# create-gh-issue

Transform user task descriptions into well-structured GitHub issues through coordinated multi-agent workflow orchestration.

**IMPORTANT**: Always use the provided scripts from `~/.claude/commands/create-gh-issue` folder. This command leverages multiple specialized agents for optimal issue quality.

**VERY IMPORTANT**: The scripts can be found in the `~/.claude/commands/create-gh-issue` folder.

## Usage

```bash
create-gh-issue [OPTIONS] <task_description>
create-gh-issue [OPTIONS] --interactive
```

## Options

- `-h, --help`: Show detailed help message with examples
- `-i, --interactive`: Interactive mode for complex requirements gathering
- `--template <type>`: Force specific issue template (task|story|project)
- `--json`: Output in JSON format for agent consumption
- `--dry-run`: Preview the issue structure without creating it
- `--repo <owner/repo>`: Target repository (defaults to current repo)
- `--labels <label1,label2>`: Comma-separated labels to add
- `--milestone <milestone>`: Milestone to assign to the issue
- `--assignee <username>`: User to assign the issue to
- `--format=FORMAT`: Output format (text|json) - json for agent use
- `--batch`: Non-interactive mode for agent execution

## Multi-Agent Workflow with Context Sharing

**MANDATORY**: This command MUST create a session context file and route through specialized agents sequentially. Never create issues directly.

### Context File Creation
**CRITICAL**: Before starting the agent workflow:
1. Generate session ID: `issue_$(date +%Y%m%d_%H%M%S)_$(echo $RANDOM)`
2. Create context file: `tasks/session_context_<session_id>.md`
3. Pass context file path to ALL agents in their prompts

The command enforces three sequential agent phases with shared context:

1. **PHASE 1 - Task-Decomposition-Expert**: Analyzes complexity and determines optimal template (updates context)
2. **PHASE 2 - Prompt-Engineer**: Optimizes descriptions for clarity and completeness (reads/updates context)
3. **PHASE 3 - Issue-Writer**: Creates the final GitHub issue with proper structure (reads/updates context)

### Agent Coordination Flow with Context
```
Create Context File →
  User Input → 
  PHASE 1: Task-Decomposition-Expert (complexity analysis, template selection) → Update Context →
  PHASE 2: Prompt-Engineer (description optimization, enhancement) → Update Context →
  PHASE 3: Issue-Writer (GitHub issue creation with structure) → Update Context →
  Issue URL Response
```

**CRITICAL**: All phases must complete before proceeding. Each agent reads the shared context file and updates it with their findings.

## Issue Templates

### Template: "task" (Simple, Single Action)
- **Trigger**: Single, specific actionable item
- **Structure**: Clear objective, acceptance criteria, implementation notes
- **Example**: "Add dark mode toggle to user settings"
- **Auto-detected when**: Simple, focused request with clear scope

### Template: "story" (Complex Feature)
- **Trigger**: Multiple related tasks or complex feature development
- **Structure**: User story format, multiple acceptance criteria, task breakdown
- **Example**: "Implement user authentication system"  
- **Auto-detected when**: Multiple components, user-facing functionality

### Template: "project" (Large Initiative)
- **Trigger**: Multiple stories/features, long-term initiative
- **Structure**: Project overview, milestone breakdown, dependencies, success metrics
- **Example**: "Build complete e-commerce platform"
- **Auto-detected when**: Cross-cutting concerns, multiple milestones

## Examples

### Human Usage

#### Simple Task Creation
```bash
# Single actionable item
create-gh-issue "Add search functionality to the user dashboard"

# Expected: Creates task-template issue with clear acceptance criteria in CURRENT repository
# Output: Issue #123 created at https://github.com/owner/repo/issues/123
```

#### Complex Feature with Interactive Mode
```bash
# Complex feature requiring clarification
create-gh-issue --interactive "Build user notification system"

# Expected: Interactive session gathering requirements
# - Shows initial analysis from task-decomposition-expert
# - Presents clarifying questions for missing information
# - Collects additional details from user
# - Displays preview of optimized issue structure
# - Confirms before creation
```

#### Force Specific Template
```bash
# Force project template for large initiative
create-gh-issue --template project "Migrate legacy API to GraphQL"

# Expected: Uses project template with milestone breakdown
```

#### Target Specific Repository
```bash
# Create issue in different repository
create-gh-issue --repo myorg/frontend "Update React to version 18"

# Expected: Creates issue in myorg/frontend repository
```

#### Add Labels and Assignment
```bash
# Create with labels and assignee
create-gh-issue --labels "enhancement,ui" --assignee "developer1" "Add dark mode support"

# Expected: Issue created with enhancement and ui labels, assigned to developer1
```

### Agent Usage

#### Proper Agent Workflow Execution with Context Sharing
```bash
# MANDATORY: Create context file and use sequential agent routing via Task tool
# NEVER use create-gh-issue directly - always route through proper agent workflow

# Step 1: Create session context file
session_id="issue_$(date +%Y%m%d_%H%M%S)_$RANDOM"
context_file="tasks/session_context_${session_id}.md"
# Initialize context file with objective

# PHASE 1: Task analysis and decomposition
Task(subagent_type="task-decomposition-expert", 
     description="Analyze issue complexity",
     prompt="Context file: ${context_file}. Analyze the following task for GitHub issue creation: 'Add user profile editing functionality'. Determine optimal template type (task/story/project), identify missing requirements, and provide structured analysis. Update context file with findings.")

# PHASE 2: Description optimization (reads context from Phase 1)
Task(subagent_type="prompt-engineer", 
     description="Optimize issue description",
     prompt="Context file: ${context_file}. Read previous analysis and optimize the description 'Add user profile editing functionality' for maximum clarity. Create structured content ready for GitHub issue creation with proper acceptance criteria and technical details. Update context file with optimized content.")

# PHASE 3: GitHub issue creation (reads context from Phase 2)
Task(subagent_type="issue-writer", 
     description="Create GitHub issue",
     prompt="Context file: ${context_file}. Read optimized content from previous phases and create a comprehensive GitHub issue. Use appropriate template, add relevant labels, and ensure professional structure. Update context file with created issue number and URL.")

# Expected: Each phase reads shared context and builds on previous findings
```

#### Complex Project Creation
```bash
# MANDATORY: Large projects require context file and all three agent phases

# Step 1: Create session context for complex project
session_id="project_$(date +%Y%m%d_%H%M%S)_$RANDOM"
context_file="tasks/session_context_${session_id}.md"

# PHASE 1: Project complexity analysis
Task(subagent_type="task-decomposition-expert", 
     description="Analyze project complexity",
     prompt="Context file: ${context_file}. Analyze complex project: 'Build complete CI/CD pipeline with Docker integration'. Break down into milestones, identify dependencies, determine project template requirements, and provide comprehensive analysis. Update context file with complete breakdown.")

# PHASE 2: Project description optimization
Task(subagent_type="prompt-engineer", 
     description="Optimize project description",
     prompt="Context file: ${context_file}. Read project analysis from context and create optimized project description for CI/CD pipeline with Docker. Include technical specifications, milestone breakdown, success criteria, and comprehensive implementation guidance. Update context with optimized structure.")

# PHASE 3: Project issue creation
Task(subagent_type="issue-writer", 
     description="Create project issue",
     prompt="Context file: ${context_file}. Read complete project structure from context and create comprehensive GitHub project issue. Apply project template, add appropriate labels (enhancement, infrastructure, ci/cd, docker), structure milestones, and ensure enterprise-ready documentation. Update context with issue URL.")

# Expected: Comprehensive project issue with shared context across all agents
```

#### Dry Run for Preview
```bash
# MANDATORY: Even dry runs must use proper agent workflow

# PHASE 1: Analysis for preview
Task(subagent_type="task-decomposition-expert", 
     description="Analyze for preview",
     prompt="Analyze 'Implement real-time chat feature' for dry-run preview. Determine template type, complexity level, and requirements structure. Provide analysis ready for description optimization.")

# PHASE 2: Description optimization for preview
Task(subagent_type="prompt-engineer", 
     description="Optimize for preview",
     prompt="Using analysis: [PHASE_1_OUTPUT], optimize 'Implement real-time chat feature' description. Create structured preview content showing what the final GitHub issue would contain, including acceptance criteria and technical notes.")

# PHASE 3: Preview structure generation (no actual GitHub creation)
Task(subagent_type="issue-writer", 
     description="Generate preview structure",
     prompt="Using optimized content: [PHASE_2_OUTPUT], generate comprehensive issue preview for 'real-time chat feature'. Show complete structure, template format, suggested labels, but do not create actual GitHub issue. Provide detailed preview of final result.")

# Expected: Complete issue preview showing structure without GitHub creation
```

## Features

### Automatic Repository Detection
- **IMPORTANT**: Creates GitHub issue in the current repository by default
- Detects current git repository using `gh repo view`
- Validates repository permissions before issue creation
- Supports cross-repository issue creation with `--repo` flag
- Graceful fallback with clear error messages
- **MANDATORY**: Always prints the GitHub issue URL at the end of execution

### Intelligent Template Selection
- **Complexity Analysis**: Uses task-decomposition-expert to assess scope
- **Content Analysis**: Examines keywords and structure for template hints
- **User Override**: Supports manual template selection with `--template`
- **Preview Mode**: Shows template choice reasoning in `--dry-run`

### Quality Validation
- **Title Optimization**: Ensures clear, actionable titles (< 80 characters)
- **Structure Enforcement**: Validates template-specific structure requirements
- **Acceptance Criteria**: Generates specific, measurable criteria
- **Technical Notes**: Includes implementation guidance when relevant
- **Label Suggestions**: Recommends appropriate labels based on content

### Multi-Agent Coordination
- **Orchestrated Workflow**: Seamless hand-off between specialized agents
- **Error Recovery**: Robust handling of agent communication failures  
- **Progress Tracking**: Clear indicators during multi-step processing
- **Caching**: Intermediate results cached to avoid re-processing
- **Timeout Management**: Prevents indefinite blocking on agent responses

## Interactive Mode Flow

**MANDATORY AGENT WORKFLOW**: When using `--interactive` flag, must route through all three agents:

1. **PHASE 1 - Task-Decomposition-Expert**: Analyzes user input and identifies gaps
2. **Gap Collection**: Gathers missing information from user via clarifying questions  
3. **PHASE 2 - Prompt-Engineer**: Optimizes description based on complete information
4. **Preview Generation**: Shows structured issue preview for user review
5. **User Confirmation**: User confirms before proceeding to creation
6. **PHASE 3 - Issue-Writer**: Creates final GitHub issue in current repository with approved content
7. **Result**: Returns issue URL and success confirmation - **MANDATORY** URL output

**CRITICAL**: Never skip agent phases. Interactive mode still requires all three sequential agent executions.

## Output Formats

### Human-Readable Output
```
✅ GitHub Issue Created Successfully in Current Repository

Title: Add dark mode toggle to user settings
Issue: #123
URL: https://github.com/owner/repo/issues/123
Template: task
Labels: enhancement, ui
Assignee: @username

📋 Issue Summary:
- Clear acceptance criteria defined
- Implementation notes included
- Ready for development

⏱️  Processing time: 2.3s
🤖 Agents used: task-decomposition-expert, prompt-engineer, issue-writer

🔗 Issue URL: https://github.com/owner/repo/issues/123
```

### JSON Output (--json flag)
```json
{
  "success": true,
  "issue": {
    "number": 123,
    "url": "https://github.com/owner/repo/issues/123",
    "title": "Add dark mode toggle to user settings",
    "template": "task",
    "labels": ["enhancement", "ui"],
    "assignee": "username",
    "milestone": null
  },
  "metrics": {
    "processing_time": "2.3s",
    "agents_used": ["task-decomposition-expert", "prompt-engineer", "issue-writer"],
    "template_confidence": 0.95,
    "enhancement_score": 8.7
  },
  "preview": {
    "title": "Add dark mode toggle to user settings",
    "body": "## Objective\n\nImplement a dark mode toggle...",
    "labels_suggested": ["enhancement", "ui", "accessibility"]
  }
}
```

### Error Output (JSON format)
```json
{
  "success": false,
  "error": {
    "code": "REPO_NOT_FOUND",
    "message": "Repository not found or insufficient permissions",
    "details": "Unable to access repository 'myorg/nonexistent'",
    "resolution": "Verify repository name and check GitHub permissions"
  },
  "context": {
    "command": "create-gh-issue",
    "repository": "myorg/nonexistent",
    "user_input": "Add new feature"
  }
}
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

### Repository Validation
- **Not in git repository**: Clear guidance to initialize or specify `--repo`
- **Repository not found**: Validates repository existence and accessibility
- **Insufficient permissions**: Checks issue creation permissions
- **Network issues**: Graceful handling with retry mechanisms

### Agent Communication
- **Agent unavailable**: Fallback to simplified processing modes
- **Timeout handling**: Prevents indefinite waiting for agent responses
- **Communication failures**: Robust error recovery and user notifications
- **Partial results**: Handles incomplete agent responses gracefully

### Input Validation
- **Empty descriptions**: Prompts for meaningful task descriptions
- **Invalid templates**: Validates template names and provides options
- **Malformed labels**: Validates label format and suggestions
- **Invalid assignees**: Checks user existence in repository context

### GitHub API Issues
- **Rate limiting**: Automatic retry with exponential backoff
- **API errors**: Detailed error messages with resolution guidance
- **Authentication failures**: Clear instructions for re-authentication
- **Permission errors**: Specific guidance for permission issues

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

#### Compatible Agents
- **task-decomposition-expert**: Primary orchestrator for complexity analysis
- **prompt-engineer**: Description optimization and enhancement
- **issue-writer**: Final issue creation with template application
- **pr-reviewer**: Can review generated issue content for quality
- **test-automator**: Can validate issue structure and format

#### Agent Capabilities Required
- **task-decomposition-expert**: Task complexity analysis, template recommendation
- **prompt-engineer**: Content optimization, structure enhancement
- **issue-writer**: GitHub issue creation, template application
- **JSON Processing**: All agents must support structured JSON communication
- **Error Handling**: Robust error reporting and recovery mechanisms

## Integration with Other Commands

### Complementary Commands
- **pr-checks**: Monitor PR status after issue implementation
- **commit-and-push**: Commit changes made during issue development
- **review-pr**: Review PRs created to address issues
- **update-tests**: Update tests as issues are implemented

### Workflow Integration
```bash
# Complete issue-to-deployment workflow
create-gh-issue "Add user authentication feature"  # Creates issue #123
# ... development work ...
commit-and-push "feat: implement user authentication (#123)"
# ... create PR ...
pr-checks https://github.com/owner/repo/pull/456  # Monitor PR checks
```

## Performance Targets

- **Simple task processing**: < 5 seconds end-to-end
- **Complex story analysis**: < 15 seconds with full agent coordination
- **Interactive mode completion**: < 30 seconds including user interaction
- **Memory usage**: < 50MB during execution
- **Concurrent execution**: Supports 3+ simultaneous instances
- **Agent coordination**: < 10 seconds for multi-agent workflows

## Troubleshooting

### Common Issues

#### "Repository not found"
```bash
# Verify you're in a git repository
git status

# Or specify repository explicitly
create-gh-issue --repo owner/repo "task description"
```

#### "GitHub CLI not authenticated"
```bash
# Authenticate with GitHub
gh auth login

# Verify authentication
gh auth status
```

#### "Agent communication timeout"
```bash
# Retry with simplified mode (bypasses some agents)
create-gh-issue --simple "task description"

# Or use dry-run to test without agent coordination
create-gh-issue --dry-run "task description"
```

#### "Invalid template selected"
```bash
# Check available templates
create-gh-issue --help

# Force specific template
create-gh-issue --template task "description"
```

### Debug Information

Enable verbose logging:
```bash
# Enable debug output
DEBUG=1 create-gh-issue "task description"

# Or use dry-run for structure preview
create-gh-issue --dry-run --verbose "task description"
```

## Quality Standards

### Issue Quality Validation
- **Title clarity**: Clear, actionable titles under 80 characters
- **Template adherence**: Proper structure following selected template
- **Acceptance criteria**: Specific, measurable, achievable criteria
- **Technical guidance**: Implementation notes when applicable
- **Label accuracy**: Relevant labels based on content analysis
- **Assignee validation**: Verified user access in repository context

### Command Quality Requirements
- **Response time**: < 10 seconds for standard workflows
- **Error recovery**: Graceful handling of all failure scenarios
- **Progress feedback**: Clear indicators during multi-step processing
- **Input validation**: Comprehensive validation with helpful error messages
- **Output consistency**: Reliable format across different input types
- **Agent reliability**: Robust coordination with timeout protection

## Agent-First Execution Requirements

**MANDATORY**: This command MUST follow Agent-First Task Execution guidelines from CLAUDE.md:

### Required Agent Routing
1. **NEVER create issues directly** - always use the three-phase agent workflow
2. **Sequential execution** - each phase must complete before the next begins
3. **Agent specialization** - each agent handles their domain expertise only
4. **Output chaining** - each agent builds on the previous agent's output

### Compliance Verification
Before using this command, verify:
- [ ] Task-decomposition-expert analyzes complexity and template requirements
- [ ] Prompt-engineer optimizes description for clarity and completeness  
- [ ] Issue-writer creates the final GitHub issue with proper structure
- [ ] All phases complete successfully before reporting completion
- [ ] No direct issue creation bypasses the agent workflow

### Enforcement Mechanisms
- Command documentation mandates agent usage at every step
- Examples show only proper Task() tool routing to agents
- Interactive mode requires all three agent phases
- Dry-run mode still routes through complete agent workflow
- All usage patterns demonstrate sequential agent coordination

This command exemplifies best practices in Agent-First multi-agent coordination while delivering practical value for GitHub issue management workflows.