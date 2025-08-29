# implement-gh-issue

Fully automated GitHub issue implementation using TDD methodology with multi-agent feedback loops.

## Overview

This command takes a GitHub issue URL and automatically:
1. **Creates context file** with complete issue information
2. **Implements solution** using TDD methodology
3. **Creates pull request** with proper linking
4. **Runs CI/CD checks** and fixes failures automatically
5. **Performs code review** and implements feedback
6. **Repeats feedback loop** until completion criteria met

## Usage

```bash
implement-gh-issue <github_issue_url>
```

The command handles everything automatically - no manual steps required.

When you run this command, Claude executes the following automated workflow:

**Instructions to give Claude:**
> "Please fully implement the GitHub issue at <github_issue_url> using this automated workflow:
> 
> 1. **SETUP PHASE:**
>    - Extract issue number and title from the GitHub issue URL using `gh issue view`
>    - Create context file at tasks/issue_<number>.md with complete issue information
>    - Create and switch to feature branch: feature/issue-<number>-<title-slug>
> 
> 2. **IMPLEMENTATION PHASE:**
>    - Read context file to understand requirements
>    - Implement solution using strict TDD methodology (RED-GREEN-REFACTOR)
>    - Write comprehensive tests first, then minimal implementation
>    - Run tests and linting to ensure quality
>    - Update context file with implementation progress
> 
> 3. **PR CREATION PHASE:**
>    - Commit changes with proper message format
>    - Push to feature branch
>    - Create pull request linking to original issue
>    - Update context file with PR URL
> 
> 4. **FEEDBACK LOOP PHASE (repeat until completion):**
>    - Use Task tool with pr-checker agent to analyze CI/CD status and failures
>    - If CI/CD passes, use Task tool with pr-reviewer agent for code quality review
>    - If fixes needed, implement them using TDD methodology
>    - Commit and push fixes
>    - Update context file with changes
>    - Continue loop until all checks pass and review approves
> 
> 5. **COMPLETION:**
>    - Verify all completion criteria met
>    - Update context file with final status
> 
> Handle all phases automatically. Use context file tasks/issue_<number>.md to track progress. Handle errors gracefully and document everything."

## How It Works

The main Claude agent handles the entire workflow by:

1. **Analyzing the GitHub issue** and extracting requirements
2. **Implementing the solution** using strict TDD methodology 
3. **Coordinating specialized agents** (pr-checker, pr-reviewer) when needed
4. **Managing the context file** to track progress across all phases
5. **Handling the feedback loop** automatically until completion criteria met

## Completion Criteria

The automated workflow completes when:
- ✅ All CI/CD checks pass
- ✅ PR reviewer indicates "Changes Required: NO"  
- ✅ PR reviewer confirms "Original Issue Requirements Met: YES"
- ✅ Context file updated with final status

## Error Handling

Claude automatically handles:
- **Invalid GitHub issue URLs**: Validates issue exists before proceeding
- **Implementation failures**: Documents blockers and suggests resolution
- **CI/CD failures**: Automatically attempts fixes using feedback from agents
- **Cycle limits**: Stops after 5 feedback cycles to prevent infinite loops

## Benefits

- **Zero manual intervention** required
- **Consistent TDD methodology** enforced
- **Automated quality checks** via CI/CD and code review
- **Complete traceability** through context file
- **Handles edge cases** and failures gracefully

Simply provide the GitHub issue URL and let the agents handle the rest.