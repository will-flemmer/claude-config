# commit-and-push

Create and push commits with automatic message length validation.

## Usage

```bash
commit-and-push.sh <commit-message>
```

## Features

- **Message validation**: Enforces 60-character limit for commit messages
- **Automatic staging**: Adds all changes with `git add -A`
- **Safe execution**: Uses `set -e` to stop on any error
- **Clear feedback**: Shows git status and confirms actions

## Examples

```bash
# Valid commit (under 60 characters)
commit-and-push.sh "fix: update validation logic"

# Invalid commit (over 60 characters) - will fail
commit-and-push.sh "this is a very long commit message that exceeds the sixty character limit"
```

## Requirements

- Must be in a git repository
- Git remote must be configured
- Proper git authentication for push

## Error Handling

- Validates commit message length before attempting commit
- Displays character count for messages that are too long
- Stops execution on any git command failure