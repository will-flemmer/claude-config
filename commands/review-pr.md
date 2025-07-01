# Review PR

Review a GitHub pull request by analyzing its changes, code quality, and potential issues.

## Usage

```
/review-pr <github-pr-url> [leave_comments=true|false]
```

## Parameters

- `<github-pr-url>`: The full GitHub pull request URL (required)
- `leave_comments`: Whether to post review comments on the PR (optional, defaults to false)

## Examples

```
# Review without leaving comments (default)
/review-pr https://github.com/owner/repo/pull/123

# Review and leave comments on the PR
/review-pr https://github.com/owner/repo/pull/123 leave_comments=true
```

## Instructions

You are an expert code reviewer. When given a GitHub PR URL:

1. Extract the owner, repo, and PR number from the URL
2. Parse the parameters to check if `leave_comments` is set to true (defaults to false)
3. Use `gh pr view <number> --repo <owner>/<repo>` to get PR details
4. Use `gh pr diff <number> --repo <owner>/<repo>` to get the full diff
5. Analyze the changes and provide a thorough code review
6. If `leave_comments=true`, post review comments on the PR using `gh pr comment` or `gh pr review`

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
- Only include significant improvements that impact functionality, security, or maintainability
- Skip minor style preferences, formatting suggestions, or subjective improvements
- Alternative approaches if applicable

### 5. Testing
- Test coverage assessment
- Suggestions for additional tests

Format your review with clear sections, use code blocks for examples, and provide actionable feedback.

## Leaving Comments

When `leave_comments=true`:

1. For general PR feedback, use:
   ```
   gh pr comment <number> --repo <owner>/<repo> --body "Your comment here"
   ```

2. For line-specific comments in the diff, use:
   ```
   gh pr review <number> --repo <owner>/<repo> --comment --body "Your review comments"
   ```

3. Structure your comments to be:
   - Constructive and specific
   - Reference line numbers or code sections
   - Focus on significant issues only (bugs, security, performance, functionality)
   - Skip minor style preferences or formatting suggestions
   - Provide examples of improvements
   - Group related comments together

4. Always provide a summary comment with:
   - Overall assessment
   - Key issues to address
   - Positive feedback on what works well

Note: When `leave_comments=false` (default), only display the review output without posting to GitHub.