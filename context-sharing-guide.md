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

## Integration with Persistent Memory

**NEW**: Context files now integrate with the persistent memory system (MCP memory server).

### Memory During Workflows

Context files are **session-scoped** (temporary), while persistent memory is **permanent** across all sessions.

**Use both together:**

| Data Type | Storage | Lifespan | Use Case |
|-----------|---------|----------|----------|
| Session progress | Context files | Single workflow | Track current task state |
| Architectural decisions | Persistent memory | Forever | Inform future decisions |
| Current blockers | Context files | Single workflow | Immediate problem-solving |
| Lessons learned | Persistent memory | Forever | Avoid repeated mistakes |
| Agent activity log | Context files | Single workflow | Workflow debugging |
| Code patterns | Persistent memory | Forever | Reuse successful patterns |

### Memory Queries in Context Files

Add a **"Relevant Past Context"** section when querying memory:

```markdown
## Relevant Past Context
### From Memory System
Queried: [timestamp]

#### Similar Past Tasks
- [Task name]: [Outcome and key decisions]
- [Task name]: [Outcome and key decisions]

#### Architectural Constraints
- [Decision]: [Rationale]
- [Pattern]: [When to use]

#### Known Issues to Avoid
- [Failed approach]: [Why it failed]
- [Gotcha]: [How to prevent]

#### Applicable Patterns
- [Pattern name]: [Where used, when to apply]
```

### Workflow Integration

#### At Workflow Start (Planning Phase)

1. Create context file with objective
2. Query persistent memory for relevant context:
   ```javascript
   const similarTasks = await mcp__memory__search_nodes({ query: "[task keywords]" });
   const architecture = await mcp__memory__open_nodes({ names: ["ProjectArchitecture"] });
   const patterns = await mcp__memory__search_nodes({ query: "[technology] patterns" });
   const failures = await mcp__memory__search_nodes({ query: "failed approach [context]" });
   ```
3. Add "Relevant Past Context" section to context file
4. Use memory findings to inform planning

#### At Workflow End (Completion Phase)

1. Extract learnings from context file
2. Store to persistent memory:
   - Architectural decisions → Architecture entities
   - New patterns → Pattern entities
   - Bugs fixed → Bug entities
   - Failed attempts → FailedApproach entities
3. Update context file with "Stored to memory: [summary]"

### Example: Memory-Enhanced Context File

```markdown
# Session Context: Implement User Authentication

## Meta
- **Session ID**: implement_20250119_143022_12345
- **Created**: 2025-11-19 14:30:22
- **Last Updated**: 2025-11-19 15:45:10 by main-agent

## Objective
Implement JWT-based authentication with refresh tokens

## Relevant Past Context
### From Memory System
Queried: 2025-11-19 14:30:25

#### Similar Past Tasks
- OAuth2 Implementation (2025-10-15): Used JWT with 15-min expiry
- Session Management Refactor (2025-11-01): Migrated from sessions to JWT

#### Architectural Constraints
- Architecture:AuthSystem: All auth must support stateless microservices
- Pattern:JWTValidation: Use middleware pattern for token validation

#### Known Issues to Avoid
- FailedApproach:LongLivedTokens: Tokens >1hr caused security issues
- Bug:TokenExpiry:ClientTime: Don't trust client time for expiry checks

## Current State
Planning completed. Ready for implementation.

## Discovered Context
### Technical Decisions
- Using JWT with 15-min access token + 7-day refresh token (based on past OAuth2 work)
- Middleware pattern for validation (reusing existing Pattern:JWTValidation)
- Server-side timestamp validation only (avoiding Bug:TokenExpiry:ClientTime)

### Dependencies
- jsonwebtoken library (v9.x)
- Redis for token blacklisting

## Agent Activity Log
### main-agent - 2025-11-19 14:30:22
**Action**: Queried memory and created task plan
**Findings**: Found 2 similar past implementations and 1 critical bug to avoid
**Next Steps**: Implement with TDD, store learnings when complete
```

### Commands Supporting Memory Integration

These commands automatically integrate with persistent memory:

**`/plan-task`**
- Queries memory at step 2 (before codebase discovery)
- Adds "Relevant Past Context" section to session context
- Informs planning with historical knowledge

**`/implement-plan`**
- Stores learnings at step 9 (after completion)
- Extracts decisions, patterns, bugs, optimizations
- Updates session context with storage confirmation

**`/init-memory`**
- Initializes memory system (one-time per project)
- Creates core entities: ProjectArchitecture, CodePatterns, BugRegistry, etc.

### Memory-Context Synergy

**Context files provide:**
- Current workflow state
- Immediate next steps
- Session-specific notes

**Persistent memory provides:**
- Historical context
- Proven patterns
- Mistakes to avoid
- Architectural constraints

**Together they enable:**
- Faster planning (leverage past work)
- Better decisions (learn from history)
- Fewer bugs (remember failures)
- Knowledge compound (improves over time)

### Best Practices for Memory Integration

1. **Always query memory** at workflow start (plan-task does this)
2. **Always store learnings** at workflow end (implement-plan does this)
3. **Keep context files temporary** - memory is permanent
4. **Reference memory in context** - cite past decisions
5. **Store selectively** - only significant learnings
6. **Update, don't duplicate** - memory entities evolve

### Troubleshooting

**Memory not initialized?**
- Run `/init-memory` in project root
- Context files still work without memory (graceful degradation)

**Memory queries slow?**
- Memory queries use MCP - should be fast
- Use parallel queries (single message, multiple MCP calls)

**Too much stored in memory?**
- Memory accumulates over time (this is good!)
- Update existing entities rather than creating duplicates
- Delete obsolete information: `mcp__memory__delete_entities`

## Implementation Checklist

- [ ] Parent agent creates context file with initial objective
- [ ] Parent agent passes context file path to child agents
- [ ] Child agents read context on start
- [ ] Child agents update relevant sections during work
- [ ] Child agents log activity before completion
- [ ] Context files are git-ignored
- [ ] Old context files are periodically cleaned up