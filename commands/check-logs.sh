#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: check-logs.sh <github-pr-url>"
    exit 1
fi

PR_URL="$1"

[[ $PR_URL =~ github.com/([^/]+)/([^/]+)/pull/([0-9]+) ]]
OWNER="${BASH_REMATCH[1]}"
REPO="${BASH_REMATCH[2]}"
PR_NUMBER="${BASH_REMATCH[3]}"

CHECK_RUNS=$(gh api "/repos/$OWNER/$REPO/commits/{pull}/$PR_NUMBER/check-runs" --jq '.check_runs[]')

echo "$CHECK_RUNS" | jq -r 'select(.conclusion == "failure") | .id + ":" + .name' | while IFS=: read -r ID NAME; do
    echo "=== $NAME ==="
    gh api "/repos/$OWNER/$REPO/actions/jobs/$ID/logs"
    echo
done