#!/bin/bash

# Function to display usage
show_usage() {
    echo "Usage: pr-checks.sh <github-pr-url> [--watch] [--interval=seconds]"
    echo "Example: pr-checks.sh https://github.com/owner/repo/pull/123"
    echo "         pr-checks.sh https://github.com/owner/repo/pull/123 --watch"
    echo "         pr-checks.sh https://github.com/owner/repo/pull/123 --interval=30"
    echo ""
    echo "Options:"
    echo "  --watch              Watch checks until they finish (auto-enabled if checks are in progress)"
    echo "  --interval=N         Set watch interval in seconds (default: 10)"
}

# Function to parse arguments
parse_arguments() {
    WATCH_MODE=false
    WATCH_INTERVAL=10
    PR_URL=""
    
    while [ $# -gt 0 ]; do
        case $1 in
            --watch)
                WATCH_MODE=true
                shift
                ;;
            --interval=*)
                WATCH_INTERVAL="${1#*=}"
                if ! [[ "$WATCH_INTERVAL" =~ ^[0-9]+$ ]] || [ "$WATCH_INTERVAL" -lt 1 ]; then
                    echo "Error: Invalid interval value. Must be a positive integer."
                    exit 1
                fi
                shift
                ;;
            https://github.com/*)
                if [ -n "$PR_URL" ]; then
                    echo "Error: Multiple URLs provided"
                    show_usage
                    exit 1
                fi
                PR_URL="$1"
                shift
                ;;
            *)
                echo "Error: Unknown argument: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Assert: Must have a URL
    if [ -z "$PR_URL" ]; then
        echo "Error: GitHub PR URL is required"
        show_usage
        exit 1
    fi
}

# Function to extract PR info from URL
extract_pr_info() {
    local url="$1"
    
    # Assert: URL must match GitHub PR pattern
    if ! [[ "$url" =~ ^https://github\.com/([^/]+)/([^/]+)/pull/([0-9]+)$ ]]; then
        echo "Error: Invalid GitHub PR URL format"
        echo "Expected format: https://github.com/owner/repo/pull/123"
        exit 1
    fi
    
    # Extract components
    OWNER="${BASH_REMATCH[1]}"
    REPO="${BASH_REMATCH[2]}"
    PR_NUM="${BASH_REMATCH[3]}"
    
    # Assert: All components must be non-empty
    if [ -z "$OWNER" ] || [ -z "$REPO" ] || [ -z "$PR_NUM" ]; then
        echo "Error: Failed to extract PR information from URL"
        exit 1
    fi
}

# Function to check gh CLI availability
check_gh_cli() {
    # Assert: gh command must be available
    if ! command -v gh &> /dev/null; then
        echo "Error: GitHub CLI (gh) is not installed"
        echo "Please install it from: https://cli.github.com/"
        exit 1
    fi
    
    # Assert: User must be authenticated
    if ! gh auth status &> /dev/null; then
        echo "Error: Not authenticated with GitHub"
        echo "Please run: gh auth login"
        exit 1
    fi
}

# Function to get PR checks status
get_pr_checks() {
    local owner="$1"
    local repo="$2"
    local pr_num="$3"
    
    echo "================================================"
    echo "PR #$pr_num Check Status for $owner/$repo"
    echo "================================================"
    echo
    
    # Get PR information
    echo "Fetching PR information..."
    local pr_info
    pr_info=$(gh pr view "$pr_num" --repo "$owner/$repo" --json state,title,headRefName 2>&1)
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to fetch PR information"
        echo "$pr_info"
        exit 1
    fi
    
    # Display PR info
    echo "$pr_info" | jq -r '"Title: \(.title)\nBranch: \(.headRefName)\nState: \(.state)"'
    echo
    
    # Get check runs
    echo "Fetching check runs..."
    local checks
    checks=$(gh pr checks "$pr_num" --repo "$owner/$repo" 2>&1)
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to fetch check runs"
        echo "$checks"
        exit 1
    fi
    
    echo "$checks"
    echo
    
    # Check if any checks are in progress
    local in_progress_checks
    in_progress_checks=$(echo "$checks" | grep -E "(pending|in_progress|queued|requested)" || true)
    
    if [ -n "$in_progress_checks" ] && [ "$WATCH_MODE" = false ]; then
        echo "⏳ Checks are in progress. Enabling watch mode..."
        echo "   Use Ctrl+C to exit watch mode"
        echo ""
        WATCH_MODE=true
    fi
    
    if [ "$WATCH_MODE" = true ]; then
        echo "👀 Watching checks (interval: ${WATCH_INTERVAL}s)..."
        echo "================================================"
        gh pr checks "$pr_num" --repo "$owner/$repo" --watch --interval="$WATCH_INTERVAL"
        echo ""
        echo "Watch completed. Fetching final status and logs..."
        echo ""
        # Refresh checks after watching
        checks=$(gh pr checks "$pr_num" --repo "$owner/$repo" 2>&1)
    fi
    
    # Get failed check logs using workflow runs
    echo "Checking for failed checks..."
    local failed_checks
    failed_checks=$(echo "$checks" | awk '$2 == "fail" || $2 == "cancelled" {print $1}' | head -5)
    
    if [ -n "$failed_checks" ]; then
        echo "================================================"
        echo "Failed Check Logs"
        echo "================================================"
        
        while IFS= read -r check_name; do
            echo
            echo "--- Logs for: $check_name ---"
            
            # Try to get logs for the failed check
            local logs
            logs=$(gh run view --repo "$owner/$repo" --job "$check_name" 2>&1 || echo "Could not fetch logs for this check")
            
            # If that doesn't work, try alternative method
            if [[ "$logs" == *"Could not fetch"* ]] || [[ "$logs" == *"error"* ]]; then
                # Get the latest workflow run for this PR
                local run_id
                run_id=$(gh run list --repo "$owner/$repo" --branch "$(echo "$pr_info" | jq -r '.headRefName')" --limit 1 --json databaseId -q '.[0].databaseId' 2>/dev/null)
                
                if [ -n "$run_id" ]; then
                    logs=$(gh run view "$run_id" --repo "$owner/$repo" --log-failed 2>&1 || echo "Logs not available")
                fi
            fi
            
            echo "$logs" | head -n 100
            echo "[Truncated to first 100 lines]"
            echo
        done <<< "$failed_checks"
    else
        echo "All checks passed or are pending!"
    fi
}

# Main execution
main() {
    parse_arguments "$@"
    
    extract_pr_info "$PR_URL"
    check_gh_cli
    get_pr_checks "$OWNER" "$REPO" "$PR_NUM"
}

# Execute main function
main "$@"