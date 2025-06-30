# pr-checks

Check the status of GitHub pull request checks and view logs for failed checks.

## Usage

```bash
pr-checks.sh <github-pr-url>
```

## Example

```bash
pr-checks.sh https://github.com/anthropics/claude-code/pull/123
```

## Features

- Shows PR title, branch, and state
- Lists all check runs with their status
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

## Error Handling

- Validates GitHub PR URL format
- Checks for `gh` CLI availability
- Verifies authentication status
- Provides clear error messages for troubleshooting