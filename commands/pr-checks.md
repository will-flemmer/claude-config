# pr-checks

Check the status of GitHub pull request checks and view logs for failed checks with automatic watch functionality.

## Usage

```bash
pr-checks.sh <github-pr-url> [--watch] [--interval=seconds]
```

## Examples

```bash
# Basic check
pr-checks.sh https://github.com/anthropics/claude-code/pull/123

# Manual watch mode
pr-checks.sh https://github.com/anthropics/claude-code/pull/123 --watch

# Custom watch interval
pr-checks.sh https://github.com/anthropics/claude-code/pull/123 --watch --interval=30
```

## Features

- Shows PR title, branch, and state
- Lists all check runs with their status
- **Auto-watch mode**: Automatically detects when checks are in progress and enables watch mode
- **Manual watch mode**: Use `--watch` flag to monitor checks until completion
- **Customizable interval**: Set watch interval with `--interval=N` (default: 10 seconds)
- Automatically fetches logs for failed checks
- Provides detailed error messages for debugging

## Requirements

- GitHub CLI (`gh`) must be installed
- Must be authenticated with `gh auth login`
- Requires `jq` for JSON parsing

## Output

The command displays:
1. PR information (title, branch, state)
2. All check runs with their current status
3. For failed checks: detailed logs (truncated to 100 lines per check)

## Analyzing Failed Checks

When a check fails, the command automatically fetches and displays the logs. To effectively debug failures:

1. **Review the error output**: Failed checks show the last 100 lines of logs
2. **Get full logs**: Use `check-logs.sh <pr-url>` to see complete logs without truncation
3. **Look for specific error messages**: Common patterns include:
   - Test failures with stack traces
   - Linting errors with file:line references
   - Build errors with compilation messages
   - Type checking errors with specific type mismatches
4. **Identify the root cause**: The logs typically show the exact command that failed and why
5. **Cross-reference with local environment**: Ensure your local setup matches the CI environment

## Post-Check Actions

Once all checks are complete, the agent should:
- **Fix failing checks**: Review the failure logs and make necessary code changes to resolve issues
- **Commit and push fixes**: Use `commit-and-push.sh "fix: <description>"` to commit and push changes
- **Monitor progress**: Continue watching until all checks pass

## Error Handling

- Validates GitHub PR URL format
- Checks for `gh` CLI availability
- Verifies authentication status
- Provides clear error messages for troubleshooting