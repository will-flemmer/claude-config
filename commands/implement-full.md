# implement-full

Comprehensive workflow command that implements a coding task using the Explore, Plan, Code methodology with TDD principles, automated PR creation, checks, and review iteration.

## CRITICAL: Complete ALL Steps

**IMPORTANT**: This workflow consists of MULTIPLE PHASES that MUST ALL be completed:
1. **Phase 1**: Implementation (Explore, Plan, Code)
2. **Phase 2**: PR Creation and Commit
3. **Phase 3**: PR Checks Monitoring
4. **Phase 4**: Code Review and Iteration

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

YOU MUST COMPLETE ALL 4 PHASES. DO NOT STOP UNTIL THE PR IS CREATED AND REVIEWED.

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

3. Stage all changes:
   git add .

4. Create a comprehensive commit with smoke test results:
   git commit -m "feat: [task description]

   Implemented using TDD methodology:
   - [list key features implemented]
   - 100% test coverage achieved
   - All quality standards met
   
   Smoke Test Results:
   - [list all manual tests performed]
   - [confirm all functionality works as expected]
   
   🤖 Generated with Claude Code
   
   Co-Authored-By: Claude <noreply@anthropic.com>"

5. Push the branch:
   git push -u origin [branch-name]

6. Create the pull request:
   gh pr create --title "feat: [task description]" --body "## Summary
   [2-3 bullet points describing what was implemented]
   
   ## Implementation Details
   - Followed TDD methodology
   - 100% test coverage
   - All quality standards met
   
   ## Testing
   - [ ] All unit tests pass
   - [ ] Manual smoke testing completed
   - [ ] Code quality checks pass
   
   ## Checklist
   - [ ] Tests written first (TDD)
   - [ ] 100% test coverage
   - [ ] Functions < 20 lines
   - [ ] Cyclomatic complexity < 5
   - [ ] At least 2 assertions per function
   - [ ] Error handling implemented
   - [ ] No code duplication
   
   🤖 Generated with Claude Code"

7. Save the PR URL for the next phase

PHASE 3: PR CHECKS (MANDATORY - DO NOT SKIP)
============================================
After creating the PR, you MUST:

1. Wait for PR checks to complete:
   gh pr checks --watch

2. If any checks fail:
   - View the detailed logs
   - Fix the issues
   - Commit and push the fixes
   - Wait for checks to re-run

3. Continue until ALL checks pass

PHASE 4: CODE REVIEW (MANDATORY - DO NOT SKIP)
==============================================
After all checks pass, you MUST:

1. Get the PR URL from Phase 2

2. Initiate a code review using:
   /review-pr [PR-URL]

3. Address ALL review feedback:
   - Make requested changes
   - Commit with descriptive messages
   - Push to update the PR

4. Continue iterating until the reviewer approves

COMPLETION CRITERIA
==================
The workflow is ONLY complete when:
✅ Implementation is done with 100% test coverage
✅ PR is created with comprehensive description
✅ All PR checks pass
✅ Code review feedback is addressed
✅ PR is approved by reviewer

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
- Perform comprehensive smoke testing

**Common Mistake**: Agents often stop here. YOU MUST CONTINUE TO PHASE 2.

### Phase 2: PR Creation and Management

This phase involves creating a feature branch, committing changes, and opening a pull request.

**Key Activities:**
- Create semantic branch name
- Make comprehensive commit with smoke test results
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

### Phase 4: Code Review Loop

This phase involves getting the code reviewed and addressing all feedback.

**Key Activities:**
- Initiate automated code review
- Read all review comments
- Make requested changes
- Commit and push updates
- Continue until approved

**Common Mistake**: Not addressing all feedback or stopping after first review.

## Requirements

- **Git**: Must be in a git repository
- **GitHub CLI (`gh`)**: Must be installed and authenticated
- **Claude Code**: Must have access to `/review-pr` command
- **Repository Access**: Must have permissions to create branches and PRs

## Troubleshooting

### Agent Only Completes Phase 1

**Problem**: The agent implements the code but doesn't create a PR.

**Solution**: 
1. Explicitly remind the agent about ALL 4 phases
2. Copy the complete workflow prompt above
3. Emphasize "DO NOT STOP until the PR is created and reviewed"

### PR Creation Fails

**Problem**: Git or GitHub CLI errors during PR creation.

**Solutions**:
- Verify `gh auth status` shows you're logged in
- Ensure you have push permissions to the repository
- Check that you're not already on a feature branch

### Checks Never Complete

**Problem**: PR checks hang or timeout.

**Solutions**:
- Use `gh pr checks` without `--watch` to see current status
- Check GitHub Actions tab in the repository
- Look for configuration issues in CI/CD

### Review Command Not Found

**Problem**: `/review-pr` command is not recognized.

**Solutions**:
- Ensure you're using Claude Code (not regular Claude)
- Check that the review-pr command is properly configured
- Try using the full command syntax with the PR URL

## Best Practices

1. **Clear Task Descriptions**: Be specific about what needs to be implemented
2. **Follow TDD Strictly**: Never write code without a failing test first
3. **Complete All Phases**: Don't let the agent stop early
4. **Address All Feedback**: Ensure every review comment is resolved
5. **Verify Completion**: Check that the PR exists and has been reviewed

## Example Execution

```
I need you to complete the ENTIRE implement-full workflow for the following task:

TASK: Create a user authentication system with JWT tokens

YOU MUST COMPLETE ALL 4 PHASES. DO NOT STOP UNTIL THE PR IS CREATED AND REVIEWED.

[... rest of the workflow prompt ...]
```

The agent should then:
1. ✅ Explore existing auth code
2. ✅ Plan JWT implementation with tests
3. ✅ Implement with TDD
4. ✅ Create branch and commit
5. ✅ Push and create PR
6. ✅ Monitor PR checks
7. ✅ Run code review
8. ✅ Address feedback
9. ✅ Continue until approved

## Common Pitfalls to Avoid

1. **Stopping After Implementation**: The workflow is NOT complete after coding
2. **Skipping Tests**: TDD means tests MUST come first
3. **Ignoring Checks**: Failed checks must be fixed before review
4. **Incomplete Reviews**: ALL feedback must be addressed
5. **No Smoke Testing**: Manual testing is required before committing

## Verification Checklist

Before considering the workflow complete, verify:
- [ ] All tests pass with 100% coverage
- [ ] Code follows all quality standards
- [ ] Branch is created and pushed
- [ ] PR is opened with proper description
- [ ] All PR checks pass
- [ ] Code review has been conducted
- [ ] All review feedback is addressed
- [ ] PR is approved

Only when ALL items are checked is the workflow truly complete.