#!/bin/bash

# Integration script to route PR failure analysis to task-decomposition-expert
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMANDS_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$(dirname "$COMMANDS_DIR")"

# Color codes
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

main() {
    local analysis_file="$1"
    
    if [ -z "$analysis_file" ] || [ ! -f "$analysis_file" ]; then
        echo "Usage: analyze-and-route.sh <analysis-file>"
        echo "This script processes PR failure analysis and routes tasks to appropriate agents"
        exit 1
    fi
    
    log "Processing PR failure analysis from: $analysis_file"
    
    # Use Claude Code's Task tool to route to task-decomposition-expert
    # This would be the integration point where Claude Code's agent system takes over
    
    # For now, we prepare the structured request
    create_task_decomposition_request "$analysis_file"
}

create_task_decomposition_request() {
    local analysis_file="$1"
    
    log "Creating task decomposition request..."
    
    # Create a structured prompt for the task-decomposition-expert
    local request_file="/tmp/task_decomposition_request.md"
    
    cat > "$request_file" << 'EOF'
# Task Decomposition Request: PR Check Failure Resolution

## Context
I have a GitHub PR with failing checks that need to be fixed. I've gathered comprehensive failure analysis including:
- Failed check details with logs
- Repository context (languages, frameworks)
- Root cause analysis for each failure
- Recommended agent assignments

## Task
Please analyze the provided failure information and create a structured plan to:
1. Route each failure type to the most appropriate specialized developer agent
2. Create prioritized task assignments with dependencies
3. Ensure fixes are implemented, tested, and pushed automatically
4. Monitor the PR until all checks pass

## Analysis Data
EOF
    
    # Append the analysis content
    cat "$analysis_file" >> "$request_file"
    
    cat >> "$request_file" << 'EOF'

## Expected Output
Please provide:
1. Task breakdown for each failure with assigned agents
2. Execution order considering dependencies
3. Success criteria for each task
4. Monitoring strategy to ensure completion

## Available Agents
- frontend-developer: React/Vue/Angular, TypeScript, styling, browser-based issues
- backend-developer: APIs, server-side logic, databases, performance
- test-automator: Unit tests, integration tests, E2E tests, test framework configuration
- devops-engineer: CI/CD, infrastructure, deployments, containerization
- security-engineer: Security vulnerabilities, compliance, access controls
- code-reviewer: Code quality, linting, formatting, best practices

Please route tasks to the most appropriate agents and create an execution plan.
EOF
    
    success "Task decomposition request created: $request_file"
    echo ""
    echo "================================================="
    echo "NEXT STEPS:"
    echo "================================================="
    echo "1. The task-decomposition-expert will analyze this request"
    echo "2. Tasks will be automatically routed to specialized agents"
    echo "3. Each agent will implement their assigned fixes"
    echo "4. Changes will be committed and pushed automatically"
    echo "5. The process will continue until all PR checks pass"
    echo ""
    echo "Request file: $request_file"
    
    # In a full Claude Code integration, this would trigger:
    # Task(subagent_type: "task-decomposition-expert", prompt: cat $request_file)
}

main "$@"