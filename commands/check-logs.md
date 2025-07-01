# check-logs

Get full logs for failed checks in a GitHub pull request.

**IMPORTANT**: Always use the provided `check-logs.sh` script. Do NOT run custom `gh` commands directly.

**VERY IMPORTANT**: The scripts can be found in the `~/.claude/commands` folder.

## Usage

```bash
./commands/check-logs.sh <github-pr-url>
```

## Example

```bash
./commands/check-logs.sh https://github.com/anthropics/claude-code/pull/123
```

## Output

Shows complete logs for all failed checks without truncation.

**Note**: This script is specifically designed to work with the pr-checks workflow. Never attempt to fetch logs using raw `gh api` commands.