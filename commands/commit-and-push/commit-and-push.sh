#!/bin/bash

set -e

if [ $# -eq 0 ]; then
    echo "Usage: commit-and-push.sh <commit-message>"
    echo "Note: Commit message must be 60 characters or less"
    exit 1
fi

COMMIT_MESSAGE="$1"

if [ ${#COMMIT_MESSAGE} -gt 60 ]; then
    echo "Error: Commit message is ${#COMMIT_MESSAGE} characters. Must be 60 characters or less."
    echo "Message: $COMMIT_MESSAGE"
    exit 1
fi

echo "Checking git status..."
git status

echo "Adding all changes..."
git add -A

echo "Creating commit with message: $COMMIT_MESSAGE"
git commit -m "$COMMIT_MESSAGE"

echo "Pushing to remote..."
git push

echo "Successfully committed and pushed: $COMMIT_MESSAGE"