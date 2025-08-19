# Command Writer Prompt: create-gh-issue Command

## Objective
Create a new Claude Code command called "create-gh-issue" that leverages multiple specialized agents to transform user task descriptions into well-structured GitHub issues with appropriate templates and quality validation.

## Command Specification

### Command Name
`create-gh-issue`

### Core Functionality
Transform user task descriptions into high-quality GitHub issues through a coordinated multi-agent workflow:
1. **Task Decomposition Expert**: Orchestrates the workflow and analyzes task complexity
2. **Prompt Engineer**: Optimizes the user input for maximum clarity and completeness
3. **Issue Writer**: Creates the final GitHub issue with appropriate template and structure

### Command Syntax
```bash
create-gh-issue [OPTIONS] <task_description>
create-gh-issue [OPTIONS] --interactive
```

### Required Parameters
- `<task_description>`: The task or project description (can be provided as arguments or interactively)

### Optional Parameters
- `--template <type>`: Force specific issue template (task|story|project)
- `--interactive, -i`: Interactive mode for complex requirements
- `--json`: Output in JSON format instead of human-readable
- `--dry-run`: Preview the issue without creating it
- `--repo <owner/repo>`: Target repository (defaults to current repo)
- `--labels <label1,label2>`: Comma-separated labels to add
- `--milestone <milestone>`: Milestone to assign
- `--assignee <username>`: User to assign the issue to

## Technical Requirements

### Agent Orchestration Pattern
```
User Input → Task-Decomposition-Expert → {
  Prompt-Engineer → Enhanced Description
  Issue-Writer → GitHub Issue Creation
} → Issue URL Response
```

### Issue Template Logic
The command must support three issue templates with automatic detection:

#### Template: "task"
- **Trigger**: Single, specific actionable item
- **Structure**: Clear objective, acceptance criteria, implementation notes
- **Example**: "Add dark mode toggle to user settings"

#### Template: "story" 
- **Trigger**: Multiple related tasks or complex feature
- **Structure**: User story format, multiple acceptance criteria, task breakdown
- **Example**: "Implement user authentication system"

#### Template: "project"
- **Trigger**: Multiple stories/features, long-term initiative
- **Structure**: Project overview, milestone breakdown, dependencies, success metrics
- **Example**: "Build complete e-commerce platform"

### Repository Detection
```bash
# Must automatically detect current repository
gh repo view --json owner,name
# Fallback error if not in git repository
```

### Error Handling Requirements
- Validate git repository context
- Confirm GitHub CLI authentication
- Handle network connectivity issues
- Validate repository permissions
- Provide clear error messages with resolution steps

## Implementation Specifications

### Agent Coordination Workflow

#### Phase 1: Task Analysis (Task-Decomposition-Expert)
```json
{
  "action": "analyze_task_complexity",
  "input": {
    "description": "<user_input>",
    "context": "github_issue_creation"
  },
  "output": {
    "complexity_level": "simple|moderate|complex",
    "template_recommendation": "task|story|project",
    "missing_information": ["list", "of", "gaps"],
    "clarifying_questions": ["array", "of", "questions"]
  }
}
```

#### Phase 2: Prompt Optimization (Prompt-Engineer)
```json
{
  "action": "optimize_issue_description",
  "input": {
    "original_description": "<user_input>",
    "template_type": "<detected_template>",
    "additional_context": "<clarifications>"
  },
  "output": {
    "optimized_title": "Clear, actionable title",
    "enhanced_description": "Structured, comprehensive description",
    "acceptance_criteria": ["criterion1", "criterion2"],
    "technical_notes": "Implementation guidance"
  }
}
```

#### Phase 3: Issue Creation (Issue-Writer)
```json
{
  "action": "create_github_issue",
  "input": {
    "repository": "owner/repo",
    "title": "<optimized_title>",
    "body": "<structured_content>",
    "labels": ["array", "of", "labels"],
    "template": "task|story|project"
  },
  "output": {
    "issue_url": "https://github.com/owner/repo/issues/123",
    "issue_number": 123,
    "status": "created|failed"
  }
}
```

### Interactive Mode Flow
When `--interactive` flag is used:
1. Present initial analysis from task-decomposition-expert
2. Show clarifying questions if any gaps identified
3. Collect additional information from user
4. Display preview of optimized issue structure
5. Confirm before creation
6. Create issue and return URL

### Output Formats

#### Human-Readable Output
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
```

#### JSON Output (--json flag)
```json
{
  "success": true,
  "issue": {
    "number": 123,
    "url": "https://github.com/owner/repo/issues/123",
    "title": "Add dark mode toggle to user settings",
    "template": "task",
    "labels": ["enhancement", "ui"],
    "assignee": "username"
  },
  "metrics": {
    "processing_time": "2.3s",
    "agents_used": ["task-decomposition-expert", "prompt-engineer", "issue-writer"]
  }
}
```

### Quality Standards

#### Issue Quality Validation
- Title is clear and actionable (< 80 characters)
- Description follows template structure
- Acceptance criteria are specific and measurable
- Technical implementation notes included when relevant
- Appropriate labels suggested based on content
- No ambiguous or vague language

#### Command Quality Requirements
- Response time < 10 seconds for simple tasks
- Graceful handling of GitHub API rate limits
- Clear progress indicators during processing
- Comprehensive error messages with solutions
- Proper cleanup on failure scenarios

## Use Cases and Examples

### Use Case 1: Simple Task
```bash
create-gh-issue "Add search functionality to the user dashboard"
```
Expected: Creates task-template issue with clear acceptance criteria

### Use Case 2: Complex Story  
```bash
create-gh-issue --interactive "Build user notification system"
```
Expected: Interactive mode gathers requirements, creates story-template issue

### Use Case 3: Project Initiative
```bash
create-gh-issue --template project "Migrate legacy API to GraphQL"
```
Expected: Forces project template, creates comprehensive project issue

### Use Case 4: Specific Repository
```bash
create-gh-issue --repo myorg/frontend "Update React to version 18"
```
Expected: Creates issue in specified repository

## Testing Requirements

### Unit Test Coverage
- Repository detection logic
- Template selection algorithm  
- Agent coordination workflow
- Error handling scenarios
- Output formatting functions

### Integration Tests
- End-to-end issue creation flow
- GitHub CLI interaction
- Multi-agent coordination
- Interactive mode workflow
- JSON output validation

### Error Scenarios to Test
- Not in git repository
- GitHub CLI not authenticated
- Network connectivity issues
- Invalid repository permissions
- Malformed user input
- API rate limit exceeded

## Performance Targets
- Simple task processing: < 5 seconds
- Complex story analysis: < 15 seconds  
- Interactive mode completion: < 30 seconds
- Memory usage: < 50MB during execution
- Concurrent execution support: 3+ instances

## Security Considerations
- Validate all user inputs to prevent injection
- Respect GitHub API rate limits
- Secure handling of authentication tokens
- No sensitive data in command logs
- Proper cleanup of temporary files

## Documentation Requirements
- Command help text with examples
- Error message explanations
- Agent interaction patterns
- Template selection logic
- Troubleshooting guide

## Implementation Notes for Command-Writer

### File Structure
```
commands/create-gh-issue/
├── create-gh-issue.md          # Command definition
├── create-gh-issue.sh          # Main execution script
├── lib/
│   ├── template-detector.sh    # Template selection logic
│   ├── repo-utils.sh          # Repository utilities
│   └── output-formatter.sh    # Output formatting
└── tests/
    ├── unit/
    └── integration/
```

### Key Implementation Considerations
1. Use task-decomposition-expert as the primary orchestrator
2. Implement robust error recovery between agent calls
3. Cache intermediate results to avoid re-processing
4. Provide clear progress feedback during multi-agent coordination
5. Follow existing Claude Code command patterns and conventions
6. Ensure compatibility with both interactive and scripted usage

This command should exemplify best practices in multi-agent coordination while delivering practical value for GitHub issue management workflows.