#!/bin/bash

# Automatic commit and push functionality for PR fixes
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMANDS_DIR="$(dirname "$SCRIPT_DIR")"

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

main() {
    local commit_message="$1"
    local pr_url="$2"
    
    if [ -z "$commit_message" ]; then
        commit_message="fix: resolve PR check failures"
    fi
    
    # Validate commit message length (60 char limit)
    if [ ${#commit_message} -gt 60 ]; then
        echo "Error: Commit message too long (${#commit_message} chars, max 60)"
        echo "Message: $commit_message"
        exit 1
    fi
    
    log "Committing fixes with message: $commit_message"
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not in a git repository"
        exit 1
    fi
    
    # Show current status
    log "Current git status:"
    git status --porcelain
    
    # Add all changes
    log "Staging all changes..."
    git add -A
    
    # Check if there are changes to commit
    if git diff --staged --quiet; then
        warning "No changes to commit"
        return 0
    fi
    
    # Create commit
    log "Creating commit..."
    git commit -m "$commit_message"
    
    # Push changes
    log "Pushing to remote..."
    git push
    
    success "Changes committed and pushed successfully!"
    
    # If PR URL provided, show next steps
    if [ -n "$pr_url" ]; then
        echo ""
        echo "Next steps:"
        echo "1. Wait for new checks to start (30-60 seconds)"
        echo "2. Monitor PR status: $pr_url"
        echo "3. Continue fixing if new failures appear"
    fi
}

main "$@"