# implement-full

Comprehensive workflow command that implements a coding task using the Explore, Plan, Code methodology with TDD principles, automated PR creation, checks, and review iteration.

## Usage

```bash
implement-full.sh <task-description>
```

## Example

```bash
implement-full.sh "Create a user authentication system with JWT tokens"
```

## Workflow Overview

The `implement-full` command orchestrates a complete development workflow:

1. **Explore Phase**: Analyzes existing codebase and requirements
2. **Plan Phase**: Creates detailed implementation plan using TDD
3. **Code Phase**: Implements solution following all coding guidelines
4. **Quality Assurance**: Runs all tests and quality checks
5. **PR Creation**: Creates branch, commits, and opens pull request
6. **Automated Review**: Runs PR checks and initiates code review
7. **Iteration Loop**: Continues until all feedback is addressed

## Detailed Workflow Steps

### Phase 1: Implementation
- Presents comprehensive task prompt to Claude
- Follows TDD methodology (Red-Green-Refactor)
- Ensures 100% test coverage
- Validates code quality standards
- Runs smoke tests on actual functionality

### Phase 2: PR Creation and Management
- Creates semantic branch name from task description
- Commits changes with detailed commit message
- Creates pull request with comprehensive description
- Saves PR URL to `pr-url.txt` for reference

### Phase 3: Quality Validation
- Waits for PR checks to complete using `pr-checks.sh`
- Monitors CI/CD pipeline status
- Reports failed checks with detailed logs
- Blocks progression until all checks pass

### Phase 4: Code Review Loop
- Clears history and enters review mode
- Runs automated PR review using `/review-pr`
- Addresses reviewer feedback with new commits
- Iterates until all comments are resolved
- Continues loop until reviewer approval

## Features

### TDD Compliance
- Enforces Test-Driven Development methodology
- Requires failing tests before implementation
- Validates 100% test coverage before completion
- Follows Red-Green-Refactor cycles

### Quality Assurance
- Validates all code quality standards from CLAUDE.md
- Ensures maximum function length (20 lines)
- Enforces maximum cyclomatic complexity (5)
- Requires at least 2 assertions per function
- Validates error handling and input validation

### Automated Workflows
- Semantic branch naming from task description
- Comprehensive commit messages with smoke test details
- PR templates with proper sections and checklists
- Automated check monitoring and failure reporting

### Review Integration
- Seamless integration with existing `review-pr` command
- Automated history clearing for clean review sessions
- Continuous iteration until all feedback addressed
- Integration with GitHub comments and reviews

## Requirements

- **GitHub CLI (`gh`)**: Must be installed and authenticated
- **Git**: Must be configured with valid repository
- **jq**: Required for JSON parsing of PR responses
- **Claude Code**: Must have access to `/review-pr` command
- **Repository Access**: Must have push permissions to create branches and PRs

## Error Handling

- Validates all required dependencies before starting
- Checks GitHub authentication status
- Verifies repository access and permissions
- Provides clear error messages for troubleshooting
- Fails fast on invalid inputs or missing tools

## Example Output

```bash
Starting implement-full workflow for: Create a user authentication system
Branch name: create-a-user-authentication-system
================================================

Starting Claude implementation workflow...
Task: Create a user authentication system
================================================

I need you to implement the following task using the Explore, Plan, Code workflow:

TASK: Create a user authentication system

Please follow these steps:
1. EXPLORE: Understand the existing codebase and requirements
2. PLAN: Create a detailed implementation plan using TDD principles
3. CODE: Implement the solution following all coding guidelines in CLAUDE.md

[Workflow continues...]
```

## Integration with Other Commands

- **`pr-checks.sh`**: Monitors PR status and displays failed check logs
- **`/review-pr`**: Conducts automated code review with GitHub integration
- **`clear`**: Built-in Claude command for history management

## Best Practices

1. **Descriptive Task Descriptions**: Use clear, specific task descriptions
2. **Follow TDD**: Always write tests first, then minimal implementation
3. **Quality First**: Never bypass quality checks or test requirements
4. **Iterative Feedback**: Address all review comments thoroughly
5. **Documentation**: Ensure code is self-documenting with clear function names

## Troubleshooting

### Common Issues

1. **Authentication Error**: Run `gh auth login` to authenticate with GitHub
2. **Missing Dependencies**: Install required tools (gh, git, jq)
3. **Branch Creation Failed**: Ensure repository is clean and accessible
4. **PR Creation Failed**: Verify repository permissions and network connectivity
5. **Review Loop Stuck**: Manually check PR comments and address all feedback

### Debug Information

The command provides detailed logging at each step:
- Dependency validation results
- Branch creation and naming
- Commit and push status  
- PR creation confirmation
- Check status monitoring
- Review iteration progress