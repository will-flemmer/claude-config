#!/bin/bash

set -e

echo "=== Update Tests Command ==="
echo "Analyzing git diff to update unit tests (add new, remove redundant) following TDD principles"

# Check git repo and changes
git rev-parse --git-dir > /dev/null 2>&1 || { echo "Error: Not in git repo"; exit 1; }
git diff --quiet && git diff --cached --quiet && { echo "No changes found"; exit 0; }

# Show changed files
echo "Changed files:"
git diff --name-only --diff-filter=AMU && git diff --cached --name-only --diff-filter=AMU | sort -u

echo "Claude will implement test updates (add new, remove redundant) for these changes."
echo "Use commands from Justfile to run tests and code quality checks."