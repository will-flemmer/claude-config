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
>    - **UPDATE CONTEXT FILE: Starting Setup Phase**
>    - Extract issue number and title from the GitHub issue URL using `gh issue view`
>    - Create context file at tasks/issue_<number>.md with complete issue information
>    - Create and switch to feature branch: feature/issue-<number>-<title-slug>
>    - **UPDATE CONTEXT FILE: Setup Phase Complete**
> 
> 2. **IMPLEMENTATION PHASE:**
>    - **UPDATE CONTEXT FILE: Starting Implementation Phase**
>    - Read context file to understand requirements
>    - Implement solution using strict TDD methodology (RED-GREEN-REFACTOR)
>    - Write comprehensive tests first, then minimal implementation
>    - Run tests and linting to ensure quality
>    - **UPDATE CONTEXT FILE: Implementation Phase Complete**
> 
> 3. **PR CREATION PHASE:**
>    - **UPDATE CONTEXT FILE: Starting PR Creation Phase**
>    - Commit changes with proper message format
>    - Push to feature branch
>    - Create pull request linking to original issue
>    - **UPDATE CONTEXT FILE: PR Creation Phase Complete (include PR URL)**
> 
> 4. **FEEDBACK LOOP PHASE (repeat until completion):**
>    - **UPDATE CONTEXT FILE: Starting Feedback Loop Cycle #N**
>    - **UPDATE CONTEXT FILE: About to call pr-checker agent**
>    - Use Task tool with pr-checker agent to analyze CI/CD status and failures
>    - **pr-checker agent MUST update context file** with their analysis and specific fix recommendations
>    - **UPDATE CONTEXT FILE: pr-checker agent complete**
>    - If CI/CD passes:
>      - **UPDATE CONTEXT FILE: About to call pr-reviewer agent**
>      - Use Task tool with pr-reviewer agent for code quality review
>      - **pr-reviewer agent MUST update context file** with review feedback and required changes
>      - **UPDATE CONTEXT FILE: pr-reviewer agent complete**
>    - **MAIN CLAUDE AGENT reads feedback from context file** and implements all fixes
>    - Implement fixes using TDD methodology based on agent feedback in context file
>    - Commit and push fixes
>    - **UPDATE CONTEXT FILE: Feedback Loop Cycle #N Complete**
>    - Continue loop until all checks pass and review approves
> 
> 5. **COMPLETION:**
>    - **UPDATE CONTEXT FILE: Starting Completion Phase**
>    - Verify all completion criteria met
>    - **UPDATE CONTEXT FILE: Final status - Implementation Complete**
> 
> Handle all phases automatically. Use context file tasks/issue_<number>.md to track progress. Handle errors gracefully and document everything."

## How It Works

The main Claude agent handles the entire workflow by:

1. **Analyzing the GitHub issue** and extracting requirements
2. **Implementing the solution** using strict TDD methodology 
3. **Updating context file before & after each phase change**
4. **Updating context file before & after each agent interaction**
5. **Coordinating specialized agents** (pr-checker, pr-reviewer) for analysis
6. **Reading agent feedback from context file** to understand required fixes
7. **Implementing all fixes directly** based on context file feedback
8. **Managing the context file** as the single source of truth for all progress
9. **Handling the feedback loop** automatically until completion criteria met

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
- **CI/CD failures**: Agents analyze and document fixes in context file, main agent implements
- **Code quality issues**: pr-reviewer documents feedback in context file, main agent implements
- **Context file communication**: Mandatory updates before/after every phase and agent change
- **Progress tracking**: Context file serves as single source of truth for all workflow state
- **Cycle limits**: Stops after 5 feedback cycles to prevent infinite loops

## Benefits

- **Zero manual intervention** required
- **Consistent TDD methodology** enforced
- **Automated quality checks** via CI/CD and code review
- **Complete traceability** through mandatory context file updates
- **Full workflow visibility** with before/after phase and agent tracking
- **Single source of truth** for all progress and communications
- **Handles edge cases** and failures gracefully

Simply provide the GitHub issue URL and let the agents handle the rest.