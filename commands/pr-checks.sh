#!/bin/bash

# Simple PR checks using gh CLI
main() {
    local url="$1"
    
    # Validate URL provided
    if [ -z "$url" ]; then
        echo "Usage: pr-checks.sh <github-pr-url>"
        exit 1
    fi
    
    # Extract PR number and repo from URL
    local pr_num=$(echo "$url" | grep -o '[0-9]*$')
    local repo=$(echo "$url" | sed 's|https://github.com/||' | sed 's|/pull/.*||')
    
    # Check PR status
    gh pr checks "$pr_num" --repo "$repo" --watch
}

main "$@"