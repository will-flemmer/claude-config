#!/bin/bash
# Template detection logic for create-gh-issue command

# Main template detection function
detect_template() {
    local description="$1"
    local confidence_threshold=${2:-0.7}
    
    # Convert to lowercase for analysis
    local desc_lower=$(echo "$description" | tr '[:upper:]' '[:lower:]')
    
    # Calculate scores for each template
    local task_score=$(calculate_task_score "$desc_lower")
    local story_score=$(calculate_story_score "$desc_lower")
    local project_score=$(calculate_project_score "$desc_lower")
    
    # Determine best match
    local max_score=0
    local best_template="task"  # default
    
    if (( $(echo "$task_score > $max_score" | bc -l) )); then
        max_score=$task_score
        best_template="task"
    fi
    
    if (( $(echo "$story_score > $max_score" | bc -l) )); then
        max_score=$story_score
        best_template="story"
    fi
    
    if (( $(echo "$project_score > $max_score" | bc -l) )); then
        max_score=$project_score
        best_template="project"
    fi
    
    echo "$best_template"
}

# Calculate task template score
calculate_task_score() {
    local desc="$1"
    local score=0
    
    # Task indicators (positive scoring)
    local task_patterns=(
        "add "
        "create "
        "implement "
        "fix "
        "update "
        "remove "
        "delete "
        "modify "
        "change "
        "improve "
        "optimize "
        "refactor "
        "configure "
        "setup "
        "install "
    )
    
    # Single action indicators
    local single_action_patterns=(
        "^(add|create|implement|fix|update|remove|delete|modify|change) [a-z]"
        "button"
        "component"
        "function"
        "method"
        "class"
        "file"
        "page"
        "endpoint"
        "api"
        "modal"
        "form"
        "field"
        "validation"
        "toggle"
        "dropdown"
        "menu"
    )
    
    # Check for task patterns
    for pattern in "${task_patterns[@]}"; do
        if [[ "$desc" =~ $pattern ]]; then
            score=$(echo "$score + 0.3" | bc -l)
        fi
    done
    
    # Check for single action patterns
    for pattern in "${single_action_patterns[@]}"; do
        if [[ "$desc" =~ $pattern ]]; then
            score=$(echo "$score + 0.4" | bc -l)
        fi
    done
    
    # Length-based scoring (tasks are typically shorter)
    local word_count=$(echo "$desc" | wc -w)
    if [[ $word_count -le 10 ]]; then
        score=$(echo "$score + 0.5" | bc -l)
    elif [[ $word_count -le 20 ]]; then
        score=$(echo "$score + 0.2" | bc -l)
    fi
    
    # Negative indicators (reduce task score)
    local anti_task_patterns=(
        "system"
        "platform"
        "application"
        "framework"
        "architecture"
        "multiple"
        "various"
        "several"
        "many"
        "complex"
        "comprehensive"
        "complete"
        "entire"
        "full"
    )
    
    for pattern in "${anti_task_patterns[@]}"; do
        if [[ "$desc" =~ $pattern ]]; then
            score=$(echo "$score - 0.2" | bc -l)
        fi
    done
    
    # Ensure non-negative score
    if (( $(echo "$score < 0" | bc -l) )); then
        score=0
    fi
    
    echo "$score"
}

# Calculate story template score
calculate_story_score() {
    local desc="$1"
    local score=0
    
    # Story indicators
    local story_patterns=(
        "user"
        "users"
        "customer"
        "customers"
        "authentication"
        "authorization"
        "login"
        "registration"
        "profile"
        "dashboard"
        "notification"
        "notifications"
        "messaging"
        "search"
        "filtering"
        "integration"
        "workflow"
        "process"
        "feature"
        "functionality"
        "experience"
        "interface"
        "interaction"
    )
    
    # Multi-component indicators
    local multi_component_patterns=(
        "and"
        "with"
        "including"
        "support"
        "supports"
        "allow"
        "allows"
        "enable"
        "enables"
        "provide"
        "provides"
        "manage"
        "manages"
        "handle"
        "handles"
    )
    
    # User story format indicators
    local user_story_patterns=(
        "as a"
        "i want"
        "i need"
        "so that"
        "in order to"
        "user can"
        "users can"
        "customer can"
        "customers can"
    )
    
    # Check story patterns
    for pattern in "${story_patterns[@]}"; do
        if [[ "$desc" =~ $pattern ]]; then
            score=$(echo "$score + 0.3" | bc -l)
        fi
    done
    
    # Check multi-component patterns
    for pattern in "${multi_component_patterns[@]}"; do
        if [[ "$desc" =~ $pattern ]]; then
            score=$(echo "$score + 0.2" | bc -l)
        fi
    done
    
    # Check user story format patterns
    for pattern in "${user_story_patterns[@]}"; do
        if [[ "$desc" =~ $pattern ]]; then
            score=$(echo "$score + 0.6" | bc -l)
        fi
    done
    
    # Length-based scoring (stories are medium length)
    local word_count=$(echo "$desc" | wc -w)
    if [[ $word_count -ge 10 && $word_count -le 30 ]]; then
        score=$(echo "$score + 0.4" | bc -l)
    elif [[ $word_count -ge 8 && $word_count -le 40 ]]; then
        score=$(echo "$score + 0.2" | bc -l)
    fi
    
    # Feature complexity indicators
    if [[ "$desc" =~ (crud|create.*read.*update.*delete) ]]; then
        score=$(echo "$score + 0.5" | bc -l)
    fi
    
    # Ensure non-negative score
    if (( $(echo "$score < 0" | bc -l) )); then
        score=0
    fi
    
    echo "$score"
}

# Calculate project template score  
calculate_project_score() {
    local desc="$1"
    local score=0
    
    # Project indicators
    local project_patterns=(
        "project"
        "platform"
        "system"
        "application"
        "app"
        "service"
        "infrastructure"
        "architecture"
        "framework"
        "migration"
        "migrate"
        "rebuild"
        "redesign"
        "overhaul"
        "replacement"
        "replace"
        "complete"
        "comprehensive"
        "entire"
        "full"
        "end-to-end"
        "e2e"
        "pipeline"
        "workflow"
        "integration"
        "ecosystem"
    )
    
    # Scale indicators
    local scale_patterns=(
        "multiple"
        "various"
        "several"
        "many"
        "all"
        "across"
        "throughout"
        "organization"
        "company"
        "enterprise"
        "scalable"
        "distributed"
        "microservices"
        "monolith"
    )
    
    # Technology migration patterns
    local migration_patterns=(
        "migrate.*to"
        "upgrade.*to" 
        "port.*to"
        "convert.*to"
        "transition.*to"
        "move.*to"
        "switch.*to"
        "adopt"
        "modernize"
        "legacy"
    )
    
    # Long-term indicators
    local longterm_patterns=(
        "roadmap"
        "strategy"
        "initiative"
        "program"
        "vision"
        "future"
        "long.term"
        "milestone"
        "milestones"
        "phase"
        "phases"
        "rollout"
        "deployment"
        "launch"
    )
    
    # Check project patterns
    for pattern in "${project_patterns[@]}"; do
        if [[ "$desc" =~ $pattern ]]; then
            score=$(echo "$score + 0.4" | bc -l)
        fi
    done
    
    # Check scale patterns
    for pattern in "${scale_patterns[@]}"; do
        if [[ "$desc" =~ $pattern ]]; then
            score=$(echo "$score + 0.3" | bc -l)
        fi
    done
    
    # Check migration patterns
    for pattern in "${migration_patterns[@]}"; do
        if [[ "$desc" =~ $pattern ]]; then
            score=$(echo "$score + 0.5" | bc -l)
        fi
    done
    
    # Check long-term patterns
    for pattern in "${longterm_patterns[@]}"; do
        if [[ "$desc" =~ $pattern ]]; then
            score=$(echo "$score + 0.4" | bc -l)
        fi
    done
    
    # Length-based scoring (projects are typically longer descriptions)
    local word_count=$(echo "$desc" | wc -w)
    if [[ $word_count -ge 20 ]]; then
        score=$(echo "$score + 0.5" | bc -l)
    elif [[ $word_count -ge 15 ]]; then
        score=$(echo "$score + 0.3" | bc -l)
    fi
    
    # Technology stack indicators
    local tech_patterns=(
        "react"
        "angular"
        "vue"
        "node"
        "python"
        "java"
        "docker"
        "kubernetes"
        "aws"
        "azure"
        "gcp"
        "database"
        "api"
        "graphql"
        "rest"
        "microservice"
        "serverless"
    )
    
    local tech_count=0
    for pattern in "${tech_patterns[@]}"; do
        if [[ "$desc" =~ $pattern ]]; then
            tech_count=$((tech_count + 1))
        fi
    done
    
    if [[ $tech_count -ge 2 ]]; then
        score=$(echo "$score + 0.6" | bc -l)
    elif [[ $tech_count -ge 1 ]]; then
        score=$(echo "$score + 0.2" | bc -l)
    fi
    
    # Ensure non-negative score
    if (( $(echo "$score < 0" | bc -l) )); then
        score=0
    fi
    
    echo "$score"
}

# Get template-specific structure recommendations
get_template_structure() {
    local template="$1"
    
    case "$template" in
        "task")
            cat << 'EOF'
{
    "sections": [
        "## Objective",
        "## Acceptance Criteria",
        "## Implementation Notes",
        "## Definition of Done"
    ],
    "title_format": "Action-oriented, specific (< 80 chars)",
    "estimated_complexity": "low",
    "typical_labels": ["enhancement", "task", "good first issue"]
}
EOF
            ;;
        "story")
            cat << 'EOF'
{
    "sections": [
        "## User Story",
        "## Background/Context", 
        "## Acceptance Criteria",
        "## Technical Requirements",
        "## Test Scenarios",
        "## Definition of Done"
    ],
    "title_format": "User-focused feature description",
    "estimated_complexity": "medium",
    "typical_labels": ["feature", "enhancement", "user-story"]
}
EOF
            ;;
        "project")
            cat << 'EOF'
{
    "sections": [
        "## Project Overview",
        "## Objectives & Success Metrics", 
        "## Scope & Deliverables",
        "## Technical Architecture",
        "## Milestone Breakdown",
        "## Dependencies & Constraints",
        "## Risk Assessment",
        "## Definition of Done"
    ],
    "title_format": "High-level initiative or system name", 
    "estimated_complexity": "high",
    "typical_labels": ["epic", "project", "architecture", "initiative"]
}
EOF
            ;;
        *)
            echo '{"error": "Unknown template type"}'
            ;;
    esac
}

# Validate template choice
validate_template() {
    local template="$1"
    case "$template" in
        "task"|"story"|"project")
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Get confidence level for template recommendation
get_template_confidence() {
    local description="$1"
    local recommended_template="$2"
    
    local desc_lower=$(echo "$description" | tr '[:upper:]' '[:lower:]')
    
    case "$recommended_template" in
        "task")
            local score=$(calculate_task_score "$desc_lower")
            ;;
        "story")
            local score=$(calculate_story_score "$desc_lower")
            ;;
        "project")
            local score=$(calculate_project_score "$desc_lower")
            ;;
        *)
            echo "0.0"
            return
            ;;
    esac
    
    # Convert score to confidence (0-1 scale)
    local confidence=$(echo "scale=2; if($score > 1.0) 1.0 else $score" | bc -l)
    echo "$confidence"
}