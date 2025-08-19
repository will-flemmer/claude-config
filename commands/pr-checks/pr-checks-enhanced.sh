#!/bin/bash

# Enhanced PR checks with intelligent failure analysis and agent routing
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMANDS_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$(dirname "$COMMANDS_DIR")"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

main() {
    local url="$1"
    
    # Validate URL provided
    if [ -z "$url" ]; then
        error "Usage: pr-checks-enhanced.sh <github-pr-url>"
        echo "Example: pr-checks-enhanced.sh https://github.com/org/repo/pull/123"
        exit 1
    fi
    
    # Validate dependencies
    if ! command -v gh &> /dev/null; then
        error "GitHub CLI (gh) is not installed. Please install it first."
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        error "jq is not installed. Please install it first."
        exit 1
    fi
    
    # Check authentication
    if ! gh auth status &> /dev/null; then
        error "Not authenticated with GitHub CLI. Run: gh auth login"
        exit 1
    fi
    
    # Extract PR number and repo from URL
    local pr_num=$(echo "$url" | grep -o '[0-9]*$')
    local repo=$(echo "$url" | sed 's|https://github.com/||' | sed 's|/pull/.*||')
    
    if [ -z "$pr_num" ] || [ -z "$repo" ]; then
        error "Invalid GitHub PR URL format. Expected: https://github.com/owner/repo/pull/123"
        exit 1
    fi
    
    log "Analyzing PR #$pr_num in $repo..."
    
    # Gather comprehensive PR information
    gather_pr_context "$repo" "$pr_num"
    
    # Check if there are failed checks and process them
    process_check_failures "$repo" "$pr_num" "$url"
}

gather_pr_context() {
    local repo="$1"
    local pr_num="$2"
    
    log "Gathering PR context..."
    
    # Get basic PR info
    local pr_info=$(gh pr view "$pr_num" --repo "$repo" --json title,body,files,additions,deletions,headRefName,baseRefName,commits)
    
    # Get repository context (languages, frameworks, etc.)
    local repo_info=$(gh api "repos/$repo" --jq '{languages_url: .languages_url}')
    local languages=$(gh api "repos/$repo/languages" | jq -r 'keys[]' 2>/dev/null || echo "[]")
    
    # Detect frameworks and tools from package files
    local frameworks=$(detect_frameworks "$repo")
    
    # Store context in temporary file for later use
    local context_file="/tmp/pr_context_${pr_num}.json"
    echo "$pr_info" | jq --argjson languages "$(echo "$languages" | jq -R . | jq -s .)" \
                          --argjson frameworks "$frameworks" \
                          '. + {repository_context: {languages: $languages, frameworks: $frameworks}}' > "$context_file"
    
    log "PR context gathered and stored"
}

detect_frameworks() {
    local repo="$1"
    local frameworks="[]"
    
    # Check for common framework indicators
    local package_json=$(gh api "repos/$repo/contents/package.json" --jq '.content' 2>/dev/null | base64 -d 2>/dev/null || echo "{}")
    local requirements_txt=$(gh api "repos/$repo/contents/requirements.txt" 2>/dev/null || echo "")
    local cargo_toml=$(gh api "repos/$repo/contents/Cargo.toml" 2>/dev/null || echo "")
    
    # Parse frameworks from package.json
    if [ "$package_json" != "{}" ]; then
        local deps=$(echo "$package_json" | jq -r '.dependencies // {} | keys[]' 2>/dev/null || echo "")
        local dev_deps=$(echo "$package_json" | jq -r '.devDependencies // {} | keys[]' 2>/dev/null || echo "")
        
        # Build frameworks array based on dependencies
        local detected=()
        for dep in $deps $dev_deps; do
            case $dep in
                react) detected+=("React") ;;
                vue) detected+=("Vue.js") ;;
                angular) detected+=("Angular") ;;
                next) detected+=("Next.js") ;;
                express) detected+=("Express") ;;
                jest) detected+=("Jest") ;;
                cypress) detected+=("Cypress") ;;
                typescript) detected+=("TypeScript") ;;
                webpack) detected+=("Webpack") ;;
                vite) detected+=("Vite") ;;
            esac
        done
        
        if [ ${#detected[@]} -gt 0 ]; then
            frameworks=$(printf '%s\n' "${detected[@]}" | jq -R . | jq -s .)
        fi
    fi
    
    echo "$frameworks"
}

process_check_failures() {
    local repo="$1"
    local pr_num="$2"
    local url="$3"
    
    log "Checking PR status and gathering failure information..."
    
    # Get check runs
    local checks_json=$(gh api "repos/$repo/pulls/$pr_num/checks" --paginate)
    
    # Parse checks and identify failures
    local failed_checks=$(echo "$checks_json" | jq '.check_runs[] | select(.conclusion == "failure" or .conclusion == "error" or .conclusion == "cancelled")')
    
    if [ -z "$failed_checks" ] || [ "$failed_checks" = "null" ]; then
        success "No failed checks found!"
        return 0
    fi
    
    log "Found failed checks. Gathering detailed failure information..."
    
    # Build comprehensive failure context
    local context_file="/tmp/pr_context_${pr_num}.json"
    local failure_context=$(build_failure_context "$repo" "$pr_num" "$url" "$failed_checks" "$context_file")
    
    # Route to task-decomposition-expert with the enhanced prompt
    route_to_task_decomposition_expert "$failure_context"
}

build_failure_context() {
    local repo="$1"
    local pr_num="$2" 
    local url="$3"
    local failed_checks="$4"
    local context_file="$5"
    
    # Get PR context
    local pr_context=$(cat "$context_file" 2>/dev/null || echo '{}')
    
    # Build failed checks array with detailed logs
    local failed_checks_array="[]"
    
    while IFS= read -r check; do
        if [ -n "$check" ] && [ "$check" != "null" ]; then
            local check_id=$(echo "$check" | jq -r '.id')
            local check_name=$(echo "$check" | jq -r '.name')
            local status=$(echo "$check" | jq -r '.conclusion // .status')
            
            # Get detailed logs for this check
            local logs=""
            local logs_response=$(gh api "repos/$repo/check-runs/$check_id" --jq '.output.text // .output.summary // "No detailed logs available"' 2>/dev/null || echo "Failed to fetch logs")
            
            # Truncate logs to reasonable size (last 2000 chars)
            logs=$(echo "$logs_response" | tail -c 2000)
            
            # Build check object
            local check_obj=$(echo "$check" | jq --arg logs "$logs" '. + {logs: $logs}')
            failed_checks_array=$(echo "$failed_checks_array" | jq --argjson check "$check_obj" '. + [$check]')
        fi
    done <<< "$(echo "$failed_checks" | jq -c '.')"
    
    # Combine all context
    local full_context=$(jq -n \
        --arg pr_url "$url" \
        --argjson pr_info "$pr_context" \
        --argjson failed_checks "$failed_checks_array" \
        '{
            pr_url: $pr_url,
            pr_info: $pr_info,
            failed_checks: $failed_checks
        }')
    
    echo "$full_context"
}

route_to_task_decomposition_expert() {
    local failure_context="$1"
    
    log "Routing to task-decomposition-expert for intelligent failure analysis..."
    
    # Load the enhanced prompt
    local prompt_file="$CONFIG_DIR/pr-check-failure-analysis-prompt.md"
    
    if [ ! -f "$prompt_file" ]; then
        error "PR failure analysis prompt not found at: $prompt_file"
        exit 1
    fi
    
    local prompt_content=$(cat "$prompt_file")
    
    # Create the full prompt with context
    local full_prompt="$prompt_content

## Input Data for Analysis

\`\`\`json
$failure_context
\`\`\`

Please analyze the above PR check failures and provide structured recommendations for routing fixes to appropriate developer agents."
    
    # Save the analysis request to a temporary file
    local analysis_file="/tmp/pr_analysis_request.md"
    echo "$full_prompt" > "$analysis_file"
    
    log "Analysis request created. Executing task-decomposition-expert..."
    
    # Execute task-decomposition-expert (this would be handled by Claude Code's agent system)
    echo "================================================="
    echo "TASK-DECOMPOSITION-EXPERT ANALYSIS REQUEST"
    echo "================================================="
    echo "Analysis file: $analysis_file"
    echo ""
    echo "Next steps:"
    echo "1. Task-decomposition-expert will analyze the failures"
    echo "2. Appropriate developer agents will be assigned"  
    echo "3. Fixes will be implemented and pushed"
    echo "4. PR checks will be re-monitored"
    echo ""
    warning "This enhanced script now provides comprehensive context for automated PR failure resolution!"
}

cleanup() {
    # Clean up temporary files
    rm -f /tmp/pr_context_*.json /tmp/pr_analysis_request.md
}

trap cleanup EXIT

main "$@"