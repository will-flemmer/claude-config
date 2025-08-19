# Review PR

Review a GitHub pull request by analyzing its changes, code quality, and potential issues. Always generates and executes smoke tests based on PR changes. All review comments and smoke test results are automatically posted to the PR.

## Usage

```
/review-pr <github-pr-url>
```

## Parameters

- `<github-pr-url>`: The full GitHub pull request URL (required)

## Examples

```
# Review with smoke testing and post all comments to PR
/review-pr https://github.com/owner/repo/pull/123
```

## Instructions

You are orchestrating a comprehensive GitHub PR review with mandatory smoke testing capabilities. Follow this multi-phase workflow with precise error handling and user feedback.

### Input Validation Phase

1. **Extract and validate parameters from the command:**
   - `github_pr_url`: GitHub PR URL (format: https://github.com/owner/repo/pull/number)

2. **Validation rules:**
   - PR URL MUST match GitHub format exactly
   - Parameters MUST be parsed as booleans
   - Invalid inputs MUST halt execution with clear error message

3. **Error response format for invalid input:**
   ```
   ❌ **Invalid Input**: [specific issue]
   **Expected Format**: /review-pr <github-pr-url>
   **Example**: /review-pr https://github.com/owner/repo/pull/123
   ```

### Execution Workflow

#### Phase 1: Standard PR Review (Always Execute)

Provide user feedback: `🔄 **Phase 1**: Conducting comprehensive PR review...`

Use the Task tool with the pr-reviewer agent:
```
Task(
  description="Comprehensive PR Review",
  prompt="Review this GitHub PR: [github-pr-url]

Focus Areas:
- Logic correctness and edge cases (PRIMARY priority)
- Code quality and maintainability
- Adherence to coding standards
- Potential bugs and error handling

Always post review comments directly on the PR using GitHub CLI with structured feedback:

REQUIRED ACTIONS:
- [Critical issues that must be fixed before merge, or 'NONE' if no critical issues]

OPTIONAL ACTIONS:
- [Recommended improvements and suggestions, or 'NONE' if no suggestions]

Expected Output:
- Logic errors and correctness issues (categorized as required or optional)
- Code quality improvements needed (categorized as required or optional)  
- Maintainability concerns (categorized as required or optional)
- Structured action items in REQUIRED/OPTIONAL format",
  subagent_type="pr-reviewer"
)
```

Update user: `✅ **Phase 1 Complete**: Review finished - [summary of key findings]`

#### Phase 2: Smoke Test Generation and Execution (Always Execute)

Provide user feedback: `🔄 **Phase 2**: Generating and executing smoke tests...`

Use the Task tool with the test-automator agent:
```
Task(
  description="Generate and Execute Smoke Tests",
  prompt="Generate and execute smoke tests for PR changes: [github-pr-url]

Requirements:
1. Analyze PR diff to identify changed functionality
2. Create focused smoke tests targeting modified code paths
3. Focus on critical user journeys and API endpoints
4. Use TDD principles with 100% coverage of critical paths
5. Generate tests that can execute in under 2 minutes

Test Categories:
- Unit tests for changed functions/classes
- Integration tests for modified API endpoints  
- End-to-end tests for altered user flows
- Regression tests for adjacent functionality

Execution Process:
1. Write test files to appropriate directories
2. Execute tests using project's test runner (check for Justfile commands)
3. Capture results with detailed output
4. Generate test coverage report

Output Format:
- Test file paths and contents
- Execution results (passed/failed)
- Test coverage report
- Any critical issues found",
  subagent_type="test-automator"
)
```

Update user: `✅ **Phase 2 Complete**: Generated [X] tests, [Y] passed, [Z] failed`

#### Phase 3: Results Consolidation and Reporting

Generate a comprehensive final report combining both phases:

```
# 📋 PR Review Summary

## 🔍 Code Review Results
[Insert pr-reviewer agent results here]

## 🧪 Smoke Test Results (if enabled)
### Generated Tests: [X] files
### Execution Results: [Y] passed, [Z] failed  
### Critical Issues: [failure details if any]
### Coverage: [percentage] of changed code

## 📊 Overall Assessment
**Recommendation**: [APPROVE/REQUEST_CHANGES/NEEDS_WORK]
**Priority Actions**: [ranked list of actions needed]
**Risk Level**: [LOW/MEDIUM/HIGH]

## 🚀 Next Steps
[specific actionable items for the PR author]
```

#### Phase 4: Comment Posting (Always Execute)

After smoke test execution, always post test results as PR comment:

```bash
# If smoke tests passed
gh pr comment [pr-number] --repo [owner/repo] --body "✅ **Smoke Tests Passed**

All generated smoke tests executed successfully:
- **Tests Generated**: [X] test files  
- **Tests Passed**: [Y]/[Y] (100%)
- **Coverage**: [Z]% of changed code
- **Execution Time**: [duration]

**Smoke Test Findings**:
- [List key areas tested and validated]
- [Any performance or behavior observations]
- [Coverage gaps if any]

REQUIRED ACTIONS:
- NONE

OPTIONAL ACTIONS:
- NONE

The PR changes have been validated and are safe to merge."

# If smoke tests failed
gh pr comment [pr-number] --repo [owner/repo] --body "❌ **Smoke Tests Failed**

Critical issues detected in smoke test execution:
- **Tests Generated**: [X] test files
- **Tests Failed**: [Y]/[Z] ([percentage]%)
- **Execution Time**: [duration]

**Smoke Test Findings**:
- [Specific test failures and error details]
- [Failed test scenarios and expected vs actual behavior]
- [Impact analysis of failures]

REQUIRED ACTIONS:
- [Critical fixes needed to make tests pass]
- [Blocking issues that prevent merge]

OPTIONAL ACTIONS:
- [Additional improvements suggested by test results]
- [Test coverage enhancements]

Please address the required actions before merging."
```

### Error Handling Protocol

#### Network/GitHub API Errors
If GitHub API fails, respond with:
```
❌ **GitHub API Error**: [specific error message]
**Resolution**: Verify PR URL exists and is accessible
**Action**: Please check the PR URL and try again
```

#### Agent Coordination Errors
If an agent fails:
```
❌ **Agent Error**: [agent-name] failed during [phase]
**Fallback**: Continuing with available results
**Impact**: [specific limitations, e.g., "Smoke testing unavailable, review complete"]
```

#### Test Framework Errors
If smoke testing fails:
```
❌ **Test Framework Error**: [specific issue]
**Alternatives**: [manual testing suggestions]
**Impact**: Smoke testing unavailable, code review complete
```

### Performance Optimization

- **Timeout**: Set 5-minute timeout per agent
- **Resource Limits**: Cap test suite to 50 tests maximum
- **Token Efficiency**: Use focused prompts to minimize token usage
- **Execution Efficiency**: Run phases sequentially, fail fast on validation errors

### Success Criteria

The command should achieve:
- >95% success rate for valid PR URLs
- 100% detection of logic errors and correctness issues
- <3 minutes total execution time
- Graceful degradation on errors
- Clear progress indication and error messages