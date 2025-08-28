# implement-gh-issue

Implements GitHub issues through automated TDD development with continuous feedback loops using specialized agents and context sharing.

**IMPORTANT**: Always use the provided scripts from `~/.claude/commands/implement-gh-issue` folder. This command leverages multiple specialized agents with shared context for optimal code quality.

## Usage

```bash
implement-gh-issue <github_issue_url>
```

## Multi-Agent Workflow with Context Sharing

**MANDATORY**: This command creates a session context file and coordinates multiple specialized agents through feedback cycles.

### Context File Creation
**CRITICAL**: Before starting the workflow:
1. Generate session ID: `implement_$(date +%Y%m%d_%H%M%S)_$RANDOM`
2. Create context file: `tasks/session_context_<session_id>.md`
3. Pass context file path to ALL agents in their prompts

### Agent Coordination Flow
```
GitHub Issue URL →
  Create Context File →
  Create Feature Branch →
  PHASE 1: TDD-Developer (initial implementation) → Update Context →
  Create Pull Request →
  FEEDBACK CYCLE (max 5 iterations):
    PHASE 2: PR-Checker (check CI/CD status) → Update Context →
    IF checks fail: TDD-Developer (fix failures) → Commit & Push → Continue Cycle
    IF checks pass: PHASE 3: PR-Reviewer (review code) → Update Context →
    IF changes required: TDD-Developer (implement feedback) → Commit & Push → Continue Cycle
    IF no changes required AND objective met: SUCCESS
  END
```

### Termination Conditions
**SUCCESS**: Cycle completes when:
- All CI/CD checks pass AND
- PR-Reviewer confirms "no changes required" AND
- PR-Reviewer confirms "objective is met"

**FAILURE**: Command terminates with error if:
- Invalid GitHub issue URL: "NO GH ISSUE FOUND"
- Initial implementation completely fails: "INITIAL IMPLEMENTATION FAILED COMPLETELY"
- 5 feedback cycles completed: "5 CYCLE LIMIT REACHED"

## Workflow Phases

### Phase 1: Initial Implementation
```bash
# Step 1: Create session context and branch
session_id="implement_$(date +%Y%m%d_%H%M%S)_$RANDOM"
context_file="tasks/session_context_${session_id}.md"
branch_name="feature/issue-$(gh issue view $issue_url --json number -q .number)-$(gh issue view $issue_url --json title -q .title | tr ' ' '-' | tr '[:upper:]' '[:lower:]')"

# Step 2: Initial TDD implementation
Task(subagent_type="tdd-developer", 
     description="Implement GitHub issue",
     prompt="Context file: ${context_file}. Read and implement the GitHub issue requirements using strict TDD methodology. Create comprehensive tests first, then implement the solution. Follow the project's existing patterns and ensure all tests pass. Update context with implementation details.")
```

### Phase 2: Feedback Cycle (Max 5 Iterations)
```bash
# Cycle tracking in context file
cycle_number=1

while [ $cycle_number -le 5 ]; do
  # Step 1: Check CI/CD status
  Task(subagent_type="pr-checker", 
       description="Check PR status",
       prompt="Context file: ${context_file}. Check the PR created from the TDD implementation. Analyze all failing checks, identify root causes, and provide specific guidance for fixes. Update context with cycle #${cycle_number} status and any failures found.")
  
  # If checks fail, fix them
  if checks_failing; then
    Task(subagent_type="tdd-developer", 
         description="Fix CI/CD failures",
         prompt="Context file: ${context_file}. Read the PR check failures from cycle #${cycle_number} and implement fixes using TDD methodology. Ensure all existing tests still pass while fixing the identified issues. Update context with fixes applied.")
    
    # Commit and push fixes
    commit-and-push "fix: address CI/CD failures from cycle ${cycle_number}"
    continue
  fi
  
  # Step 2: Code review (only if checks pass)
  Task(subagent_type="pr-reviewer", 
       description="Review implementation",
       prompt="Context file: ${context_file}. Review the PR implementation for cycle #${cycle_number}. Provide structured feedback on code quality, adherence to requirements, and completeness. Clearly state if changes are required and if the objective is met. Update context with review findings.")
  
  # Check review outcome
  if changes_required; then
    Task(subagent_type="tdd-developer", 
         description="Address review feedback",
         prompt="Context file: ${context_file}. Read the PR review feedback from cycle #${cycle_number} and implement the requested changes using TDD methodology. Ensure all tests pass and requirements are fully met. Update context with changes made.")
    
    # Commit and push changes
    commit-and-push "refactor: address PR review feedback from cycle ${cycle_number}"
  else
    # SUCCESS: All checks pass, no changes required, objective met
    echo "✅ Implementation completed successfully!"
    exit 0
  fi
  
  cycle_number=$((cycle_number + 1))
done

# FAILURE: 5 cycle limit reached
echo "❌ 5 CYCLE LIMIT REACHED"
exit 1
```

## Context File Structure

The shared context file tracks the entire implementation process:

```markdown
# Session Context: Implement Issue #123 - Add User Authentication

## Meta
- **Session ID**: implement_20240115_143052_12345
- **Created**: 2024-01-15 14:30:52
- **Last Updated**: 2024-01-15 15:45:23 by pr-reviewer
- **GitHub Issue**: https://github.com/owner/repo/issues/123
- **Pull Request**: https://github.com/owner/repo/pull/456
- **Branch**: feature/issue-123-add-user-authentication

## Objective
Implement user authentication system with OAuth support as specified in GitHub issue #123.

## Current State
Cycle 2/5 - PR review feedback received, implementing changes

## Implementation History
### Initial Implementation
- **TDD-Developer**: Created authentication service with comprehensive tests
- **Tests Added**: 15 unit tests, 3 integration tests
- **Files Modified**: AuthService.js, UserController.js, auth.test.js

### Cycle 1
- **PR-Checker**: All CI/CD checks passed ✅
- **PR-Reviewer**: Requested security improvements and error handling
- **Changes Required**: Input validation, rate limiting, better error messages

### Cycle 2 (Current)
- **TDD-Developer**: Implementing security improvements from review feedback
- **In Progress**: Adding input validation and rate limiting middleware

## Discovered Context
### Requirements
- OAuth 2.0 with Google and GitHub providers
- Session management with Redis
- Rate limiting for login attempts
- Comprehensive error handling

### Technical Decisions
- Using passport.js for OAuth implementation
- JWT tokens with 24-hour expiration
- Redis for session storage
- Express rate limiting middleware

### Test Coverage
- Current: 95% line coverage
- Target: 100% line coverage
- All edge cases covered

## Agent Activity Log
### tdd-developer - Initial Implementation - 2024-01-15 14:45:00
**Action**: Implemented OAuth authentication system using TDD methodology
**Tests Created**: 18 comprehensive tests covering all functionality
**Files Modified**: 8 files created/modified
**Next Steps**: Create PR and begin review cycle

### pr-checker - Cycle 1 - 2024-01-15 15:10:00
**Action**: Analyzed CI/CD pipeline status
**Findings**: All tests pass, linting clean, build successful
**Status**: All checks passing ✅
**Next Steps**: Proceed to code review

### pr-reviewer - Cycle 1 - 2024-01-15 15:25:00
**Action**: Conducted comprehensive code review
**Findings**: Implementation correct but needs security hardening
**Changes Required**: YES
**Objective Met**: PARTIAL - functionality complete, security needs improvement
**Next Steps**: Implement security improvements

### tdd-developer - Cycle 2 - 2024-01-15 15:45:00
**Action**: Implementing security improvements from review feedback
**Changes**: Adding input validation, rate limiting, enhanced error handling
**Status**: IN_PROGRESS
**Next Steps**: Complete changes and run tests

## Blockers & Issues
- None currently

## Working Notes
[Current agent workspace - cleared after each agent completes]
```

## Agent Updates Required

### TDD-Developer Enhancements
- **PR Feedback Integration**: Read and understand PR review feedback
- **Iterative Development**: Handle multiple cycles of feedback and improvements
- **Context Tracking**: Update context with cycle-specific progress

### PR-Checker Enhancements
- **Context Integration**: Read previous cycle results to avoid repeating analysis
- **Failure Categorization**: Classify failures by type (tests, linting, build, security)
- **Cycle Awareness**: Track which cycle is being analyzed

### PR-Reviewer Enhancements
- **Structured Feedback**: Provide clear pass/fail criteria
- **Objective Verification**: Explicitly state if original issue requirements are met
- **Change Requirements**: Clearly indicate if changes are required or optional

## Command Options

```bash
implement-gh-issue <github_issue_url>         # Standard implementation workflow
implement-gh-issue --dry-run <github_issue_url>  # Preview workflow without execution
implement-gh-issue --max-cycles N <url>       # Override 5-cycle limit (max 10)
implement-gh-issue --branch-name <name> <url> # Override auto-generated branch name
```

## Error Handling

### Invalid Issue URL
```bash
# Input validation
if ! gh issue view "$issue_url" >/dev/null 2>&1; then
  echo "❌ NO GH ISSUE FOUND"
  exit 1
fi
```

### Initial Implementation Failure
```bash
# Check if TDD-Developer completed successfully
if [ "$tdd_exit_code" -ne 0 ]; then
  echo "❌ INITIAL IMPLEMENTATION FAILED COMPLETELY"
  exit 1
fi
```

### Cycle Limit Protection
```bash
# Prevent infinite loops
if [ $cycle_number -gt 5 ]; then
  echo "❌ 5 CYCLE LIMIT REACHED"
  exit 1
fi
```

## Integration Requirements

### Dependencies
- **GitHub CLI** (`gh`): Issue reading, PR creation, status checking
- **Git**: Branch management, commit operations
- **commit-and-push**: Automated commit and push functionality
- **Claude Code agents**: tdd-developer, pr-checker, pr-reviewer

### Repository Requirements
- Must be run from within a git repository
- GitHub repository must be accessible
- User must have push permissions
- CI/CD pipeline should be configured for automated checks

## Output Format

```bash
🚀 Starting implementation of issue #123: Add User Authentication
📝 Context file: tasks/session_context_implement_20240115_143052_12345.md
🌿 Created branch: feature/issue-123-add-user-authentication

⚙️  Phase 1: TDD Implementation
✅ TDD-Developer completed initial implementation
📊 Tests: 18 created, 100% passing
📝 Files: 8 modified

🔄 Pull Request created: https://github.com/owner/repo/pull/456

🔄 Feedback Cycle 1/5
🔍 PR-Checker: All CI/CD checks passing ✅
👀 PR-Reviewer: Changes required - security improvements needed
⚙️  TDD-Developer: Implementing security enhancements

🔄 Feedback Cycle 2/5
🔍 PR-Checker: All CI/CD checks passing ✅
👀 PR-Reviewer: No changes required ✅ Objective met ✅

✅ Implementation completed successfully!
🔗 PR: https://github.com/owner/repo/pull/456
📊 Cycles used: 2/5
⏱️  Total time: 8m 32s
```

This command represents the pinnacle of Agent-First development, combining TDD methodology with continuous feedback loops to ensure high-quality implementations that fully satisfy GitHub issue requirements.