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

## Multi-Agent Workflow

The command orchestrates three specialized agents:

1. **Task-Decomposition-Expert**: Analyzes complexity and determines optimal template
2. **Prompt-Engineer**: Optimizes descriptions for clarity and completeness  
3. **Issue-Writer**: Creates the final GitHub issue with proper structure

### Agent Coordination Flow
```
User Input → Task-Decomposition-Expert → {
  Prompt-Engineer → Enhanced Description
  Issue-Writer → GitHub Issue Creation
} → Issue URL Response
```

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

# Expected: Creates task-template issue with clear acceptance criteria
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

#### Basic Agent Invocation
```bash
# Agent invocation via Task tool
Task(prompt="/create-gh-issue --format=json --batch 'Add user profile editing functionality'")

# Expected JSON response:
{
  "success": true,
  "issue": {
    "number": 123,
    "url": "https://github.com/owner/repo/issues/123",
    "title": "Add user profile editing functionality",
    "template": "task",
    "labels": ["enhancement"],
    "assignee": null
  },
  "metrics": {
    "processing_time": "3.2s",
    "agents_used": ["task-decomposition-expert", "prompt-engineer", "issue-writer"]
  }
}
```

#### Complex Project Creation
```bash
# Large project with agent coordination
Task(prompt="/create-gh-issue --format=json --template=project 'Build complete CI/CD pipeline with Docker integration'")

# Expected: Multi-agent workflow creates comprehensive project issue
```

#### Dry Run for Preview
```bash
# Preview issue structure without creation
Task(prompt="/create-gh-issue --dry-run --format=json 'Implement real-time chat feature'")

# Expected: Shows structured issue preview without GitHub creation
```

## Features

### Automatic Repository Detection
- Detects current git repository using `gh repo view`
- Validates repository permissions before issue creation
- Supports cross-repository issue creation with `--repo` flag
- Graceful fallback with clear error messages

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

When using `--interactive` flag:

1. **Initial Analysis**: Task-decomposition-expert analyzes user input
2. **Gap Identification**: Shows missing information and clarifying questions
3. **Information Gathering**: Collects additional requirements from user
4. **Enhancement**: Prompt-engineer optimizes based on complete information
5. **Preview**: Displays structured issue preview for review
6. **Confirmation**: User confirms before creation
7. **Creation**: Issue-writer creates final GitHub issue
8. **Result**: Returns issue URL and success confirmation

## Output Formats

### Human-Readable Output
```
✅ GitHub Issue Created Successfully

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

This command exemplifies best practices in multi-agent coordination while delivering practical value for GitHub issue management workflows.