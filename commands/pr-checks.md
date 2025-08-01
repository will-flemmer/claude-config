# pr-checks

Check the status of GitHub pull request checks and view logs for failed checks with automatic watch functionality.

**IMPORTANT**: Always use the provided scripts from `~/.claude/commands/pr-checks` folder. Do NOT run custom `gh` commands directly.

**VERY IMPORTANT**: The scripts can be found in the `~/.claude/commands/pr-checks` folder.

## Usage

```bash
pr-checks.sh <github-pr-url>
```

## Examples

```bash
pr-checks.sh https://github.com/anthropics/claude-code/pull/123
```

## Features

- Shows PR title, branch, and state
- Lists all check runs with their status
- **Auto-watch mode**: Automatically detects when checks are in progress and enables watch mode
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
2. **Get full logs**: Use `pr-checks/check-logs.sh <pr-url>` to see complete logs without truncation
3. **Look for specific error messages**: Common patterns include:
   - Test failures with stack traces
   - Linting errors with file:line references
   - Build errors with compilation messages
   - Type checking errors with specific type mismatches
4. **Identify the root cause**: The logs typically show the exact command that failed and why
5. **Cross-reference with local environment**: Ensure your local setup matches the CI environment

## Iterative Fix Workflow

The agent should follow this iterative process:

1. **Run pr-checks**: `./commands/pr-checks/pr-checks.sh <pr-url>`
2. **WAIT FOR CHECKS TO COMPLETE**: 
   - **CRITICAL**: Use `sleep 60` to wait for checks to finish running
   - Checks take time to execute - DO NOT analyze incomplete results
   - Keep using `sleep 60` and re-running pr-checks AS MANY TIMES AS NEEDED until all checks show a final state (passed/failed)
   - Some checks may take several minutes - keep waiting and checking repeatedly
3. **When checks fail**:
   - Analyze the failure logs (use `./commands/pr-checks/check-logs.sh <pr-url>` for full logs)
   - Fix the identified issues in the code
   - Use `./commands/commit-and-push.sh "fix: <description>"` to commit and push
4. **WAIT AGAIN**: After pushing, use `sleep 60` to allow new checks to start and complete
5. **Continue watching**: The pushed changes will trigger new checks
6. **Repeat until all checks pass**: Keep watching and fix any new failures
7. **Success**: Only stop when all checks show as passed

**EXTREMELY IMPORTANT**: 
- **ALWAYS USE `sleep 60`** between check runs to allow GitHub Actions to complete
- After pushing fixes, do NOT exit. Keep watching the PR to ensure the fixes resolve all issues
- Wait for checks to reach a final state (not "in progress") before analyzing
- Always use the provided scripts (pr-checks.sh, check-logs.sh, commit-and-push.sh)
- Do NOT run custom `gh` or `git` commands directly

## Error Handling

- Validates GitHub PR URL format
- Checks for `gh` CLI availability
- Verifies authentication status
- Provides clear error messages for troubleshooting