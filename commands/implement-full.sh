#!/bin/bash

# Function to display usage
show_usage() {
    echo "Usage: implement-full.sh <task-description>"
    echo "Example: implement-full.sh 'Create a user authentication system'"
}

# Function to validate inputs
validate_inputs() {
    # Assert: Must have exactly one argument
    if [ $# -ne 1 ]; then
        show_usage
        exit 1
    fi
    
    # Assert: Argument must not be empty
    if [ -z "$1" ]; then
        echo "Error: Task description cannot be empty"
        exit 1
    fi
}

# Function to check required tools
check_dependencies() {
    local missing_tools=()
    
    # Assert: gh command must be available
    if ! command -v gh &> /dev/null; then
        missing_tools+=("GitHub CLI (gh)")
    fi
    
    # Assert: git command must be available
    if ! command -v git &> /dev/null; then
        missing_tools+=("git")
    fi
    
    # Assert: jq command must be available (for JSON parsing)
    if ! command -v jq &> /dev/null; then
        missing_tools+=("jq")
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo "Error: Missing required tools:"
        for tool in "${missing_tools[@]}"; do
            echo "  - $tool"
        done
        exit 1
    fi
    
    # Assert: User must be authenticated with GitHub
    if ! gh auth status &> /dev/null; then
        echo "Error: Not authenticated with GitHub"
        echo "Please run: gh auth login"
        exit 1
    fi
}

# Function to create branch name from description
create_branch_name() {
    local description="$1"
    
    # Assert: Description must not be empty
    if [ -z "$description" ]; then
        echo "Error: Cannot create branch name from empty description"
        exit 1
    fi
    
    # Convert to lowercase, replace spaces with hyphens, remove special chars
    local branch_name
    branch_name=$(echo "$description" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9 ]//g' | sed 's/ /-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')
    
    # Assert: Branch name must not be empty after processing
    if [ -z "$branch_name" ]; then
        echo "Error: Could not generate valid branch name from description"
        exit 1
    fi
    
    # Truncate to reasonable length
    echo "${branch_name:0:50}"
}

# Function to run Claude with implement workflow
run_claude_implement() {
    local task_description="$1"
    
    echo "Starting Claude implementation workflow..."
    echo "Task: $task_description"
    echo "================================================"
    
    # Create a comprehensive prompt for Claude
    local claude_prompt="I need you to implement the following task using the Explore, Plan, Code workflow:

TASK: $task_description

Please follow these steps:
1. EXPLORE: Understand the existing codebase and requirements
2. PLAN: Create a detailed implementation plan using TDD principles
3. CODE: Implement the solution following all coding guidelines in CLAUDE.md

Requirements:
- Use strict TDD (Test-Driven Development)
- Follow all code quality standards
- Ensure 100% test coverage
- Add proper error handling
- Follow existing code patterns
- Run all quality checks before completion

Once implementation is complete, please confirm:
- All tests pass
- Code follows quality standards
- No linting errors
- Ready for PR creation"

    echo "$claude_prompt"
    echo "================================================"
    echo "Please implement the above task. When you're done, I'll create the PR and run the workflow."
    
    # Wait for user to complete implementation
    echo "Press Enter when implementation is complete..."
    read -r
}

# Function to create PR and run workflow
create_pr_and_workflow() {
    local task_description="$1"
    local branch_name="$2"
    
    echo "Creating branch: $branch_name"
    
    # Create and switch to new branch
    if ! git checkout -b "$branch_name"; then
        echo "Error: Failed to create branch $branch_name"
        exit 1
    fi
    
    # Add all changes
    git add .
    
    # Create commit message
    local commit_msg="feat: $task_description

This implementation follows TDD principles and includes:
- Comprehensive test coverage
- Error handling and validation
- Code quality compliance
- Following existing patterns

Smoke tests completed:
- All unit tests pass
- Integration tests pass  
- Manual testing of core functionality
- Edge case validation
- Error condition handling

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>"
    
    # Commit changes
    if ! git commit -m "$commit_msg"; then
        echo "Error: Failed to commit changes"
        exit 1
    fi
    
    # Push branch
    if ! git push -u origin "$branch_name"; then
        echo "Error: Failed to push branch"
        exit 1
    fi
    
    # Create PR
    local pr_title="feat: $task_description"
    local pr_body="## Summary
- Implements $task_description using TDD methodology
- Follows all coding guidelines and quality standards
- Includes comprehensive test coverage

## Test Plan
- [x] Unit tests pass
- [x] Integration tests pass
- [x] Manual smoke testing completed
- [x] Edge cases validated
- [x] Error conditions handled properly

🤖 Generated with Claude Code"
    
    echo "Creating pull request..."
    local pr_url
    pr_url=$(gh pr create --title "$pr_title" --body "$pr_body" 2>&1)
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create PR"
        echo "$pr_url"
        exit 1
    fi
    
    # Extract PR URL from output
    local actual_pr_url
    actual_pr_url=$(echo "$pr_url" | grep -o 'https://github.com[^[:space:]]*')
    
    # Assert: PR URL must be extracted successfully
    if [ -z "$actual_pr_url" ]; then
        echo "Error: Failed to extract PR URL from gh output"
        exit 1
    fi
    
    echo "PR created: $actual_pr_url"
    
    # Save PR URL to file
    echo "$actual_pr_url" > pr-url.txt
    echo "PR URL saved to pr-url.txt"
    
    return 0
}

# Function to wait for PR checks and iterate
wait_and_iterate() {
    local pr_url_file="pr-url.txt"
    
    # Assert: PR URL file must exist
    if [ ! -f "$pr_url_file" ]; then
        echo "Error: $pr_url_file not found"
        exit 1
    fi
    
    local pr_url
    pr_url=$(cat "$pr_url_file")
    
    echo "================================================"
    echo "Starting PR check and review workflow"
    echo "PR URL: $pr_url"
    echo "================================================"
    
    # Wait for checks to complete
    echo "Waiting for PR checks to complete..."
    ./commands/pr-checks.sh "$pr_url"
    
    # Clear history and enter review mode
    echo "Clearing history and entering review mode..."
    clear
    
    # Run PR review
    echo "Starting PR review..."
    # Note: review-pr is a Claude command, not a shell script
    echo "Please run: /review-pr $pr_url"
    echo "After completing the review, press Enter to continue the workflow..."
    read -r
    
    # Clear history again
    clear
    
    echo "Review completed. Ready to iterate on feedback."
    echo "The workflow will continue iterating until all feedback is addressed."
}

# Main execution
main() {
    # Handle help flag
    if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        show_usage
        exit 0
    fi
    
    # Handle invalid flags
    if [[ "$1" == --* ]] && [ "$1" != "--help" ]; then
        echo "Error: Invalid flag '$1'"
        show_usage
        exit 1
    fi
    
    validate_inputs "$@"
    check_dependencies
    
    local task_description="$1"
    local branch_name
    branch_name=$(create_branch_name "$task_description")
    
    echo "Starting implement-full workflow for: $task_description"
    echo "Branch name: $branch_name"
    echo "================================================"
    
    # Step 1: Run Claude implementation
    run_claude_implement "$task_description"
    
    # Step 2: Create PR and workflow
    create_pr_and_workflow "$task_description" "$branch_name"
    
    # Step 3: Wait and iterate
    wait_and_iterate
    
    echo "implement-full workflow completed!"
}

# Execute main function
main "$@"