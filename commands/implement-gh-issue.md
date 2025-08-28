# implement-gh-issue

Implements GitHub issues through TDD methodology with automated feedback loops using context-sharing agents.

## Overview

This workflow guides you through implementing a GitHub issue using:
- **TDD-Developer**: Implements features using Test-Driven Development
- **PR-Checker**: Analyzes CI/CD failures and provides fix guidance
- **PR-Reviewer**: Reviews code quality and requirements compliance

All agents share context through a session file to maintain continuity.

## Usage

```bash
implement-gh-issue <github_issue_url>
```

## Workflow

### 1. Setup
Create a context file and feature branch for the GitHub issue.

Example for issue: https://github.com/owner/repo/issues/123

**Get issue information:**
```
gh issue view https://github.com/owner/repo/issues/123
```
This shows you the complete issue to copy into the context file.

**Create files:**
- Context file: `tasks/issue_<number>.md`  
- Feature branch: `feature/issue-<number>-<title-slug>`

### 2. Create Context File
Copy the **complete** GitHub issue into a context file:

```
# Issue #<number> - <title>

## Meta
- **GitHub Issue**: <github_issue_url>
- **Branch**: feature/issue-<number>-<title-slug>

## GitHub Issue (Complete)

### Title
Add User Authentication

### Number
#123

### Description
[Paste the complete GitHub issue body here - everything from the issue]

### Labels
- enhancement
- backend
- security

### Assignee
@username

### Acceptance Criteria
[Copy any acceptance criteria from the issue or comments]

### Additional Context
[Copy any relevant comments or clarifications from the GitHub issue thread]

## Current State
Ready for TDD implementation

## Agent Activity Log
[Agents will update this section]

## Working Notes
[Current agent workspace]
```

### 3. TDD Implementation
Copy and paste this exact Task command:

```
Task(subagent_type="tdd-developer", 
     description="Implement GitHub issue using TDD",
     prompt="Context file: tasks/issue_<number>.md. Read the complete GitHub issue from the context file and implement the requirements using strict TDD methodology - create comprehensive tests first, then implement the solution following existing project patterns. Update the context file with your implementation progress.")
```

**Replace `<number>` with the actual issue number.**

### 4. Create Pull Request
After TDD implementation is complete:

1. Commit changes with message: "feat: implement issue #123 - Add User Authentication"
2. Push to branch: `feature/issue-123-add-user-authentication`
3. Create PR with title: "feat: Add User Authentication"
4. Link to issue in PR body: "Closes #123"

### 5. Feedback Loop (Repeat until complete)

#### Check CI/CD Status
Copy and paste this Task command:

```
Task(subagent_type="pr-checker", 
     description="Check PR CI/CD status",
     prompt="Context file: tasks/issue_<number>.md. Check the pull request for failing CI/CD checks. Analyze any failures by type and urgency, then provide specific guidance for fixes. Update the context file with your analysis.")
```

**Replace `<number>` with the actual issue number.**

#### If CI/CD passes, do code review
Copy and paste this Task command:

```
Task(subagent_type="pr-reviewer", 
     description="Review PR implementation",
     prompt="Context file: tasks/issue_<number>.md. Review the pull request implementation for code quality, security, performance, and adherence to the original GitHub issue requirements. Use the mandatory structured format to clearly indicate if changes are required and if the objective is met. Update the context file with your review findings.")
```

**Replace `<number>` with the actual issue number.**

#### If fixes needed
Copy and paste this Task command:

```
Task(subagent_type="tdd-developer", 
     description="Implement fixes",
     prompt="Context file: tasks/issue_<number>.md. Read the feedback from previous agents (pr-checker or pr-reviewer) and implement the necessary fixes using TDD methodology. Ensure all existing tests still pass while addressing the feedback. Update the context file with the changes you made.")
```

**Replace `<number>` with the actual issue number.**

Then commit and push the fixes.

## Completion Criteria

The workflow is complete when:
- ✅ All CI/CD checks pass
- ✅ PR reviewer indicates "Changes Required: NO"
- ✅ PR reviewer confirms "Original Issue Requirements Met: YES"

## Context File Structure

The shared context file maintains:
- **Meta**: Session info, issue URL, branch name
- **Objective**: GitHub issue requirements
- **Current State**: Implementation progress
- **Agent Activity Log**: What each agent accomplished
- **Working Notes**: Temporary workspace for current agent

## Error Conditions

- **Invalid GitHub issue**: "NO GH ISSUE FOUND"
- **Implementation failure**: "INITIAL IMPLEMENTATION FAILED COMPLETELY"
- **Too many cycles**: Stop after 5 feedback cycles

## Agent Updates Required

All three agents have been updated to:
- Read context files using Read tool
- Update context files using Edit tool
- Work iteratively through feedback cycles
- Provide structured, actionable feedback

This workflow ensures high-quality implementations that fully satisfy GitHub issue requirements through continuous TDD and feedback loops.