# Agent Context Sharing Implementation Guide

## Overview
This guide defines how agents share context through markdown files to maintain continuity across multi-agent workflows.

## Context File Pattern

### File Location
Context files are stored at: `<project-root>/tasks/session_context_<session_id>.md`
- `session_id` is passed from the parent agent/coordinator
- Parent agent creates the initial context file
- Files are git-ignored to prevent committing temporary context

### File Structure

```markdown
# Session Context: [Task/Issue/PR Title]

## Meta
- **Session ID**: [unique-id]
- **Created**: [timestamp]
- **Last Updated**: [timestamp by agent-name]
- **Parent Task**: [reference to parent task/issue/PR]

## Objective
[Clear statement of the overall goal]

## Current State
[Summary of what has been accomplished and current status]

## Discovered Context
### Requirements
- [Discovered requirements/constraints]

### Technical Decisions  
- [Key technical decisions made and rationale]

### Dependencies
- [External dependencies identified]

## Agent Activity Log
### [Agent Name] - [Timestamp]
**Action**: [What the agent did]
**Findings**: [Key discoveries]
**Next Steps**: [Recommended actions for next agent]

## Blockers & Issues
- [Any blocking issues encountered]

## Working Notes
[Scratch space for current agent - cleared/summarized by next agent]
```

## Agent Behavior

### On Task Start
1. Check if context file path is provided in prompt
2. Read the context file if it exists
3. Parse current state and objective
4. Review previous agent findings and recommendations

### During Task Execution
1. Use Working Notes section for temporary thoughts
2. Update Discovered Context as new information is found
3. Track any blockers in appropriate section

### On Task Completion
1. Update Current State with accomplishments
2. Add entry to Agent Activity Log with:
   - Brief summary of actions taken
   - Key findings/decisions
   - Recommendations for next steps
3. Clear Working Notes or summarize important points
4. Update Last Updated timestamp

## Update Strategies

### Section-Based Updates (Preferred)
- **Current State**: Replace with updated summary
- **Discovered Context**: Merge new findings into existing subsections
- **Agent Activity Log**: Append new entry (compress if >10 entries)
- **Working Notes**: Clear or summarize

### Compression Strategy
When Agent Activity Log exceeds 10 entries:
1. Summarize older entries into Current State
2. Keep only last 3-5 entries
3. Preserve critical decisions in Technical Decisions

## Applicable Agents

This pattern applies to:
- `issue-writer`: Creates context when drafting complex issues
- `pr-checker`: Shares findings from CI/CD checks
- `pr-reviewer`: Documents review findings and suggestions
- `task-decomposition-expert`: Breaks down tasks with shared understanding
- `prompt-engineer`: Maintains context for prompt iterations

## Example Usage

### Parent Agent Creates Context
```markdown
# When invoking a specialized agent
session_id = "task_20240115_implement_auth"
create_context_file(session_id, objective="Implement OAuth authentication")
invoke_agent(agent="issue-writer", 
            prompt=f"Create an issue for OAuth implementation. Context: tasks/session_context_{session_id}.md")
```

### Child Agent Reads and Updates
```markdown
# Agent starts task
context = read_file(f"tasks/session_context_{session_id}.md")
# ... performs work ...
update_context_sections(
    current_state="Created GitHub issue #123 with OAuth requirements",
    technical_decisions=["Using OAuth 2.0 with PKCE flow"],
    activity_log="issue-writer: Created comprehensive issue with acceptance criteria"
)
```

## Best Practices

1. **Keep Updates Concise**: Focus on actionable information
2. **Preserve Critical Context**: Don't delete important discoveries
3. **Use Structured Data**: Lists and headers for easy parsing
4. **Time-stamp Important Events**: Include timestamps for debugging
5. **Clear Working Notes**: Don't leave temporary thoughts for next agent
6. **Reference External Resources**: Link to PRs, issues, docs
7. **Fail Gracefully**: Continue if context file is missing/corrupt

## Implementation Checklist

- [ ] Parent agent creates context file with initial objective
- [ ] Parent agent passes context file path to child agents
- [ ] Child agents read context on start
- [ ] Child agents update relevant sections during work
- [ ] Child agents log activity before completion
- [ ] Context files are git-ignored
- [ ] Old context files are periodically cleaned up