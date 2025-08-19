#!/bin/bash
# Repository utilities for create-gh-issue command

# Get current repository in owner/repo format
get_current_repo() {
    local repo_info
    
    # First try to get repo info from GitHub CLI
    if repo_info=$(gh repo view --json owner,name 2>/dev/null); then
        local owner=$(echo "$repo_info" | jq -r '.owner.login')
        local name=$(echo "$repo_info" | jq -r '.name')
        echo "$owner/$name"
        return 0
    fi
    
    # Fallback: try to extract from git remote
    local remote_url
    if remote_url=$(git config --get remote.origin.url 2>/dev/null); then
        # Handle both SSH and HTTPS formats
        if [[ "$remote_url" =~ git@github\.com:([^/]+)/([^.]+)\.git ]]; then
            echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
            return 0
        elif [[ "$remote_url" =~ https://github\.com/([^/]+)/([^/]+)\.git ]]; then
            echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
            return 0
        elif [[ "$remote_url" =~ https://github\.com/([^/]+)/([^/]+) ]]; then
            echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
            return 0
        fi
    fi
    
    # If all fails, return error
    return 1
}

# Validate repository exists and is accessible
validate_repository() {
    local repo="$1"
    
    # Check if repository exists and is accessible
    if ! gh repo view "$repo" >/dev/null 2>&1; then
        return 1
    fi
    
    # Check if we have permission to create issues
    local permissions
    if permissions=$(gh api "repos/$repo" --jq '.permissions' 2>/dev/null); then
        if [[ "$(echo "$permissions" | jq -r '.push // false')" == "true" ]] || 
           [[ "$(echo "$permissions" | jq -r '.admin // false')" == "true" ]]; then
            return 0
        fi
    fi
    
    # If permissions check fails, try a simpler check
    # Try to list issues (this requires read access at minimum)
    if gh issue list --repo "$repo" --limit 1 >/dev/null 2>&1; then
        return 0
    fi
    
    return 1
}

# Check if we're in a git repository
is_git_repository() {
    git rev-parse --git-dir >/dev/null 2>&1
}

# Get repository default branch
get_default_branch() {
    local repo="$1"
    gh repo view "$repo" --json defaultBranchRef --jq '.defaultBranchRef.name' 2>/dev/null || echo "main"
}

# Extract repository info from various URL formats
parse_repo_url() {
    local url="$1"
    
    # GitHub issue URL
    if [[ "$url" =~ github\.com/([^/]+)/([^/]+)/issues ]]; then
        echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
        return 0
    fi
    
    # GitHub PR URL  
    if [[ "$url" =~ github\.com/([^/]+)/([^/]+)/pull ]]; then
        echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
        return 0
    fi
    
    # GitHub repository URL
    if [[ "$url" =~ github\.com/([^/]+)/([^/]+)/?$ ]]; then
        echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
        return 0
    fi
    
    # Direct owner/repo format
    if [[ "$url" =~ ^[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+$ ]]; then
        echo "$url"
        return 0
    fi
    
    return 1
}

# Check GitHub CLI authentication
check_gh_auth() {
    if ! gh auth status >/dev/null 2>&1; then
        return 1
    fi
    return 0
}

# Get current user's GitHub username
get_gh_username() {
    gh api user --jq '.login' 2>/dev/null || echo ""
}

# Check if user has specific permissions on repository
check_repo_permission() {
    local repo="$1"
    local permission="$2"  # push, pull, admin, maintain, triage
    
    local perms
    if perms=$(gh api "repos/$repo" --jq '.permissions' 2>/dev/null); then
        [[ "$(echo "$perms" | jq -r ".$permission // false")" == "true" ]]
    else
        return 1
    fi
}

# Get repository topics/labels for auto-labeling
get_repo_topics() {
    local repo="$1"
    gh repo view "$repo" --json repositoryTopics --jq '.repositoryTopics[].name' 2>/dev/null || echo ""
}

# List available labels in repository
get_repo_labels() {
    local repo="$1"
    gh label list --repo "$repo" --json name --jq '.[].name' 2>/dev/null || echo ""
}

# Validate label exists in repository
validate_label() {
    local repo="$1"
    local label="$2"
    
    gh label list --repo "$repo" --json name --jq '.[].name' 2>/dev/null | grep -q "^$label$"
}

# Get repository milestones
get_repo_milestones() {
    local repo="$1"
    gh api "repos/$repo/milestones" --jq '.[].title' 2>/dev/null || echo ""
}

# Validate milestone exists in repository
validate_milestone() {
    local repo="$1"
    local milestone="$2"
    
    get_repo_milestones "$repo" | grep -q "^$milestone$"
}

# Check if user exists and has access to repository
validate_assignee() {
    local repo="$1"
    local username="$2"
    
    # Check if user exists
    if ! gh api "users/$username" >/dev/null 2>&1; then
        return 1
    fi
    
    # Check if user has access to repository (can be assigned)
    if gh api "repos/$repo/collaborators/$username" >/dev/null 2>&1; then
        return 0
    fi
    
    # For public repos, check if user is a contributor
    if gh api "repos/$repo/contributors" --jq '.[].login' 2>/dev/null | grep -q "^$username$"; then
        return 0
    fi
    
    return 1
}