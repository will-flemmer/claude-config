#!/bin/bash
# Output formatting utilities for create-gh-issue command

# Format success output for human consumption
format_human_success() {
    local issue_data="$1"
    local metrics="$2"
    local dry_run="${3:-false}"
    
    # Extract data using jq
    local number=$(echo "$issue_data" | jq -r '.number')
    local url=$(echo "$issue_data" | jq -r '.url')
    local title=$(echo "$issue_data" | jq -r '.title')
    local template=$(echo "$issue_data" | jq -r '.template')
    local labels=$(echo "$issue_data" | jq -r '.labels[]?' | tr '\n' ',' | sed 's/,$//')
    local assignee=$(echo "$issue_data" | jq -r '.assignee // "none"')
    local milestone=$(echo "$issue_data" | jq -r '.milestone // "none"')
    local processing_time=$(echo "$metrics" | jq -r '.processing_time')
    local agents_used=$(echo "$metrics" | jq -r '.agents_used | join(", ")')
    
    if [[ "$dry_run" == "true" ]]; then
        echo "🔍 GitHub Issue Preview (Dry Run)"
        echo "=================================="
        echo ""
        echo "Title: $title"
        echo "Template: $template"
        echo "Labels: ${labels:-none}"
        echo "Assignee: $assignee"
        echo "Milestone: $milestone"
        echo ""
        echo "📋 Preview Summary:"
        echo "- Structure follows $template template"
        echo "- Ready for creation when confirmed"
        echo "- Estimated processing time: $processing_time"
        echo ""
        echo "🤖 Agents involved: $agents_used"
        echo ""
        echo "Note: Use without --dry-run to create the actual issue"
    else
        echo "✅ GitHub Issue Created Successfully"
        echo ""
        echo "Title: $title"
        echo "Issue: #$number"
        echo "URL: $url"
        echo "Template: $template"
        echo "Labels: ${labels:-none}"
        echo "Assignee: $assignee"
        echo "Milestone: $milestone"
        echo ""
        echo "📋 Issue Summary:"
        echo "- Clear acceptance criteria defined"
        echo "- Implementation notes included"
        echo "- Ready for development"
        echo ""
        echo "⏱️  Processing time: $processing_time"
        echo "🤖 Agents used: $agents_used"
    fi
}

# Format JSON success output
format_json_success() {
    local issue_data="$1"
    local metrics="$2"
    local preview_data="${3:-{}}"
    local dry_run="${4:-false}"
    
    jq -n \
        --arg success "true" \
        --argjson issue "$issue_data" \
        --argjson metrics "$metrics" \
        --argjson preview "$preview_data" \
        --arg dry_run "$dry_run" \
        '{
            success: ($success | test("true")),
            issue: $issue,
            metrics: $metrics,
            preview: (if $dry_run == "true" then $preview else null end),
            dry_run: ($dry_run == "true")
        }'
}

# Format error output for human consumption
format_human_error() {
    local error_code="$1"
    local message="$2"
    local resolution="${3:-Please check the command usage and try again}"
    local context="${4:-}"
    
    echo "❌ Error: $message"
    echo ""
    echo "Code: $error_code"
    echo "Resolution: $resolution"
    
    if [[ -n "$context" ]]; then
        echo ""
        echo "Context:"
        echo "$context" | sed 's/^/  /'
    fi
    
    echo ""
    echo "For help, run: create-gh-issue --help"
}

# Format JSON error output
format_json_error() {
    local error_code="$1"
    local message="$2"
    local resolution="${3:-Please check the command usage and try again}"
    local context="${4:-{}}"
    
    jq -n \
        --arg success "false" \
        --arg code "$error_code" \
        --arg message "$message" \
        --arg resolution "$resolution" \
        --argjson context "$context" \
        '{
            success: ($success | test("true")),
            error: {
                code: $code,
                message: $message,
                resolution: $resolution
            },
            context: $context
        }'
}

# Format progress messages for human output
format_progress() {
    local step="$1"
    local message="$2"
    local output_format="${3:-text}"
    
    if [[ "$output_format" != "json" ]]; then
        case "$step" in
            "analyze")
                echo "🔍 $message"
                ;;
            "enhance") 
                echo "✨ $message"
                ;;
            "create")
                echo "📝 $message"
                ;;
            "validate")
                echo "✅ $message"
                ;;
            "error")
                echo "❌ $message"
                ;;
            *)
                echo "ℹ️  $message"
                ;;
        esac
    fi
}

# Format template analysis results
format_template_analysis() {
    local analysis="$1"
    local output_format="${2:-text}"
    
    if [[ "$output_format" == "json" ]]; then
        echo "$analysis"
    else
        local complexity=$(echo "$analysis" | jq -r '.complexity_level')
        local template=$(echo "$analysis" | jq -r '.template_recommendation')
        local confidence=$(echo "$analysis" | jq -r '.template_confidence // "0.85"')
        local missing_info=$(echo "$analysis" | jq -r '.missing_information[]?' | tr '\n' ',' | sed 's/,$//')
        
        echo "📊 Analysis Results:"
        echo "   Complexity: $complexity"
        echo "   Recommended template: $template"
        echo "   Confidence: $(echo "scale=0; $confidence * 100" | bc)%"
        
        if [[ -n "$missing_info" ]]; then
            echo "   Missing information: $missing_info"
        fi
    fi
}

# Format interactive prompts
format_interactive_prompt() {
    local prompt_type="$1"
    local message="$2"
    local options="${3:-}"
    
    case "$prompt_type" in
        "question")
            echo "❓ $message"
            ;;
        "choice")
            echo "🎯 $message"
            if [[ -n "$options" ]]; then
                echo "$options" | jq -r '.[]' | sed 's/^/   • /'
            fi
            ;;
        "confirm")
            echo "🤔 $message (y/N): "
            ;;
        "input")
            echo "✏️  $message: "
            ;;
        *)
            echo "$message"
            ;;
    esac
}

# Format issue preview
format_issue_preview() {
    local title="$1"
    local body="$2"
    local template="$3"
    local output_format="${4:-text}"
    
    if [[ "$output_format" == "json" ]]; then
        jq -n \
            --arg title "$title" \
            --arg body "$body" \
            --arg template "$template" \
            '{
                title: $title,
                body: $body,
                template: $template,
                preview: true
            }'
    else
        echo "📝 Issue Preview:"
        echo "=================="
        echo "Title: $title"
        echo "Template: $template"
        echo ""
        echo "$body" | sed 's/\\n/\n/g'
        echo ""
    fi
}

# Format validation results
format_validation_result() {
    local validation_type="$1"
    local result="$2"
    local details="${3:-}"
    local output_format="${4:-text}"
    
    if [[ "$output_format" == "json" ]]; then
        jq -n \
            --arg type "$validation_type" \
            --arg result "$result" \
            --arg details "$details" \
            '{
                validation_type: $type,
                result: $result,
                details: $details
            }'
    else
        local icon="✅"
        if [[ "$result" != "valid" ]]; then
            icon="❌"
        fi
        
        echo "$icon $validation_type: $result"
        if [[ -n "$details" ]]; then
            echo "   Details: $details"
        fi
    fi
}

# Format agent coordination status
format_agent_status() {
    local agent="$1"
    local status="$2"
    local message="${3:-}"
    local output_format="${4:-text}"
    
    if [[ "$output_format" != "json" ]]; then
        local icon=""
        case "$status" in
            "starting")
                icon="🚀"
                ;;
            "processing")
                icon="⚡"
                ;;
            "completed")
                icon="✅"
                ;;
            "failed")
                icon="❌"
                ;;
            *)
                icon="ℹ️"
                ;;
        esac
        
        if [[ -n "$message" ]]; then
            echo "$icon Agent $agent: $message"
        else
            echo "$icon Agent $agent: $status"
        fi
    fi
}

# Format metrics summary
format_metrics() {
    local metrics="$1"
    local output_format="${2:-text}"
    
    if [[ "$output_format" == "json" ]]; then
        echo "$metrics"
    else
        local processing_time=$(echo "$metrics" | jq -r '.processing_time')
        local agents_used=$(echo "$metrics" | jq -r '.agents_used | join(", ")')
        local template_confidence=$(echo "$metrics" | jq -r '.template_confidence // "N/A"')
        local enhancement_score=$(echo "$metrics" | jq -r '.enhancement_score // "N/A"')
        
        echo "📊 Processing Metrics:"
        echo "   Time: $processing_time"
        echo "   Agents: $agents_used"
        echo "   Template confidence: $template_confidence"
        echo "   Enhancement score: $enhancement_score"
    fi
}

# Format help sections
format_help_section() {
    local section="$1"
    local content="$2"
    
    echo ""
    echo "$section"
    echo "${section//?/=}"
    echo "$content"
}

# Color support detection and functions
has_color_support() {
    [[ -t 1 ]] && [[ "${TERM:-}" != "dumb" ]] && command -v tput >/dev/null 2>&1
}

# Color codes (only used if color is supported)
if has_color_support; then
    COLOR_RED=$(tput setaf 1)
    COLOR_GREEN=$(tput setaf 2)
    COLOR_YELLOW=$(tput setaf 3)
    COLOR_BLUE=$(tput setaf 4)
    COLOR_MAGENTA=$(tput setaf 5)
    COLOR_CYAN=$(tput setaf 6)
    COLOR_RESET=$(tput sgr0)
    COLOR_BOLD=$(tput bold)
else
    COLOR_RED=""
    COLOR_GREEN=""
    COLOR_YELLOW=""
    COLOR_BLUE=""
    COLOR_MAGENTA=""
    COLOR_CYAN=""
    COLOR_RESET=""
    COLOR_BOLD=""
fi

# Colorize output (only if color is supported and not JSON)
colorize() {
    local color="$1"
    local text="$2"
    local output_format="${3:-text}"
    
    if [[ "$output_format" == "json" ]] || ! has_color_support; then
        echo "$text"
    else
        case "$color" in
            "red") echo "${COLOR_RED}${text}${COLOR_RESET}" ;;
            "green") echo "${COLOR_GREEN}${text}${COLOR_RESET}" ;;
            "yellow") echo "${COLOR_YELLOW}${text}${COLOR_RESET}" ;;
            "blue") echo "${COLOR_BLUE}${text}${COLOR_RESET}" ;;
            "magenta") echo "${COLOR_MAGENTA}${text}${COLOR_RESET}" ;;
            "cyan") echo "${COLOR_CYAN}${text}${COLOR_RESET}" ;;
            "bold") echo "${COLOR_BOLD}${text}${COLOR_RESET}" ;;
            *) echo "$text" ;;
        esac
    fi
}