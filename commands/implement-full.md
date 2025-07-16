# implement-full

Comprehensive workflow command that implements a coding task using the Explore, Plan, Code methodology with TDD principles, and PR checks.

## CRITICAL: Complete ALL Steps

**IMPORTANT**: This workflow consists of MULTIPLE PHASES that MUST ALL be completed:
1. **Phase 1**: Implementation (Explore, Plan, Code)
2. **Phase 2**: PR Creation and Commit
3. **Phase 3**: PR Checks Monitoring
4. **Phase 4**: Completion

**The agent MUST complete ALL phases. Do NOT stop after Phase 1.**

## Usage

This is a Claude Code workflow command. To execute:

1. Clear your Claude Code session history
2. Copy and paste the ENTIRE workflow prompt below
3. Replace `[TASK DESCRIPTION]` with your specific task
4. Submit to Claude Code

## Complete Workflow Prompt

```
I need you to complete the ENTIRE implement-full workflow for the following task:

TASK: [TASK DESCRIPTION]

YOU MUST COMPLETE ALL 4 PHASES. DO NOT STOP UNTIL THE PR IS CREATED AND CHECKS PASS.

PHASE 1: IMPLEMENTATION
======================
1. EXPLORE: Understand the existing codebase and requirements
   - Search for related files and patterns
   - Read existing code to understand conventions
   - Identify where new code should be placed

2. PLAN: Create a detailed implementation plan using TDD principles
   - List all test cases to write
   - Define the API/interface
   - Break down into RED-GREEN-REFACTOR cycles

3. CODE: Implement the solution following ALL coding guidelines in CLAUDE.md
   - Write failing tests first (RED)
   - Write minimal code to pass (GREEN)
   - Refactor to improve quality (REFACTOR)
   - Ensure 100% test coverage
   - Run all tests and quality checks
   - Perform manual smoke testing

PHASE 2: PR CREATION (MANDATORY - DO NOT SKIP)
==============================================
After completing implementation, you MUST:

1. Create a semantic branch name from the task description
   Example: "create-user-authentication-system"

2. Create the branch and switch to it:
   git checkout -b [branch-name]

3. Use the commit-and-push script for committing:
   ./commands/commit-and-push.sh "feat: [short task description]"
   
   **IMPORTANT**: Keep commit message under 60 characters. Use the PR description for detailed information.

4. If you need to push a new branch:
   git push -u origin [branch-name]

6. Create the pull request: `gh pr create`
   - use the commit message as PR title
   - use PR template as body

7. Save the PR URL for the next phase

PHASE 3: PR CHECKS (MANDATORY - DO NOT SKIP)
============================================
After creating the PR, you MUST:

1. Use the pr-checks script to monitor:
   ./commands/pr-checks/pr-checks.sh [PR-URL]

2. If any checks fail:
   - Use ./commands/pr-checks/check-logs.sh [PR-URL] for detailed logs
   - Fix the issues
   - Use ./commands/commit-and-push/commit-and-push.sh "fix: [description]" to push fixes
   - Continue watching with ./commands/pr-checks/pr-checks.sh [PR-URL]

3. Continue until ALL checks pass

**IMPORTANT**: Always use the provided scripts. Never run raw git or gh commands.

**VERY IMPORTANT**: The scripts can be found in the `~/.claude/commands` folder. Read the `.md` files in this directory to find the correct script to use.

PHASE 4: COMPLETION
==================
After all checks pass, the workflow is complete.

COMPLETION CRITERIA
==================
The workflow is ONLY complete when:
✅ Implementation is done with 100% test coverage
✅ PR is created with comprehensive description
✅ All PR checks pass

DO NOT STOP until ALL criteria are met.
```

## Detailed Phase Descriptions

### Phase 1: Implementation (Explore, Plan, Code)

This phase involves understanding the codebase and implementing the solution using TDD.

**Key Activities:**
- Search and read existing code
- Create a TDD implementation plan
- Write tests first, then implementation
- Ensure all quality standards are met

**Common Mistake**: Agents often stop here. YOU MUST CONTINUE TO PHASE 2.

### Phase 2: PR Creation and Management

This phase involves creating a feature branch, committing changes, and opening a pull request.

**Key Activities:**
- Create semantic branch name
- Commit changes
- Push to remote repository
- Create PR with detailed description
- Save PR URL for later phases

**Common Mistake**: Forgetting to push or create the PR. ALL steps are required.

### Phase 3: Quality Validation

This phase ensures all automated checks pass before proceeding to review.

**Key Activities:**
- Monitor PR check status
- Review failed check logs
- Fix any issues found
- Re-run checks until all pass

**Common Mistake**: Not waiting for checks or ignoring failures.

### Phase 4: Completion

This phase marks the end of the workflow after all checks pass.

**Key Activities:**
- Verify all checks have passed
- Confirm PR is ready for review by others

**Common Mistake**: Stopping before all checks pass.

## Requirements

- **Git**: Must be in a git repository
- **GitHub CLI (`gh`)**: Must be installed and authenticated
- **Repository Access**: Must have permissions to create branches and PRs

## Best Practices

1. **Clear Task Descriptions**: Be specific about what needs to be implemented
2. **Follow TDD Strictly**: Never write code without a failing test first
3. **Complete All Phases**: Don't let the agent stop early
4. **Verify Completion**: Check that the PR exists and all checks pass

## Example Execution

```
I need you to complete the ENTIRE implement-full workflow for the following task:

TASK: Create a user authentication system with JWT tokens

YOU MUST COMPLETE ALL 4 PHASES. DO NOT STOP UNTIL THE PR IS CREATED AND CHECKS PASS.

[... rest of the workflow prompt ...]
```

The agent should then:
1. ✅ Explore existing auth code
2. ✅ Plan JWT implementation with tests
3. ✅ Implement with TDD
4. ✅ Create branch and commit
5. ✅ Push and create PR
6. ✅ Monitor PR checks
7. ✅ Verify all checks pass

## Common Pitfalls to Avoid

1. **Stopping After Implementation**: The workflow is NOT complete after coding
2. **Skipping Tests**: TDD means tests MUST come first
3. **Ignoring Checks**: Failed checks must be fixed
4. **No Smoke Testing**: Manual testing is required before committing

## Verification Checklist

Before considering the workflow complete, verify:
- [ ] All tests pass with 100% coverage
- [ ] Code follows all quality standards
- [ ] Branch is created and pushed
- [ ] PR is opened with proper description
- [ ] All PR checks pass

Only when ALL items are checked is the workflow truly complete.