# Review PR

Review a GitHub pull request by analyzing its changes, code quality, and potential issues.

## Usage

```
/review-pr <github-pr-url>
```

## Example

```
/review-pr https://github.com/owner/repo/pull/123
```

## Instructions

You are an expert code reviewer. When given a GitHub PR URL:

1. Extract the owner, repo, and PR number from the URL
2. Use `gh pr view <number> --repo <owner>/<repo>` to get PR details
3. Use `gh pr diff <number> --repo <owner>/<repo>` to get the full diff
4. Analyze the changes and provide a thorough code review

Your review should include:

### 1. Overview
- What the PR accomplishes
- Main changes and their purpose

### 2. Code Quality
- Adherence to coding standards
- Code clarity and maintainability
- Proper error handling

### 3. Potential Issues
- Bugs or logic errors
- Security vulnerabilities
- Performance concerns

### 4. Suggestions
- Specific improvements with examples
- Alternative approaches if applicable

### 5. Testing
- Test coverage assessment
- Suggestions for additional tests

Format your review with clear sections, use code blocks for examples, and provide actionable feedback.