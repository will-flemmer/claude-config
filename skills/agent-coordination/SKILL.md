---
name: agent-coordination
description: Use when facing complex tasks requiring specialized expertise or when CLAUDE.md agent routing table indicates specific agent should handle the work - orchestrates multi-agent workflows with context sharing, proper task delegation, and result synthesis
---

# Agent Coordination

## Overview

Complex tasks often require specialized agents. Agent coordination manages task delegation, context sharing, execution monitoring, and result synthesis across multiple agents.

**Core principle:** Route tasks to specialized agents with clear context, monitor execution, synthesize results.

## When to Use

Use agent coordination when:
- Task matches specialized agent in CLAUDE.md routing table
- Multiple independent sub-tasks can be parallelized
- Need code review, PR management, or issue creation
- Planning requires specialized analysis
- Task complexity benefits from focused expertise

**Handle directly when:**
- Simple operations (git status, file reads)
- Immediate clarifications
- Agent routing decisions
- Single-step tasks within your capability

## Agent Routing Table

Based on CLAUDE.md, route tasks as follows:

| Task Type | Agent | Context Required | Notes |
|-----------|-------|------------------|-------|
| Code implementation | main Claude agent | Yes* | Use TDD, context files |
| Code review/quality | pr-reviewer | Yes* | After implementation |
| PR management | pr-checker | Yes* | Monitor and fix PR checks |
| Issue creation | issue-writer | Yes* | From planning docs |
| Task planning | main Claude agent | Yes* | Use /plan-task command |
| Command creation | command-writer | No | Standalone scripts |
| Prompt optimization | prompt-engineer | Yes* | Improve agent prompts |

*Context-sharing agents MUST use session files at `tasks/session_context_<id>.md`

## Context Sharing Protocol

**MANDATORY** for all context-sharing agents:

### 1. Create Session Context File

Before invoking any agent:

```bash
session_id="<workflow>_$(date +%Y%m%d_%H%M%S)_$RANDOM"
context_file="tasks/session_context_${session_id}.md"
```

**Initialize context file** with:
- Objective
- Workflow type
- Current state
- Technical decisions (if any)
- Activity log

**REQUIRED**: Use the @context-file-management skill for structure.

### 2. Start Agent Prompt with Context Path

**CRITICAL:** Every context-sharing agent prompt MUST start with:

```
Context file: tasks/session_context_<session_id>.md

[Detailed task instructions]
```

**Example:**
```
Context file: tasks/session_context_plan_20251122_143022_12345.md

Create GitHub issue based on task plan from planning phase. The plan
document is at tasks/user_auth_oauth2_20251122_143022_12345.md.

Read both files to understand context and requirements.
```

### 3. Agent Responsibilities

Context-sharing agents must:
1. **Read** context file at start
2. **Extract** relevant information (objective, constraints, decisions)
3. **Update** context file sections on completion
4. **Log** significant actions in Activity Log
5. **Return** summary of work completed

## Task Delegation Patterns

### Pattern 1: Sequential Delegation

**Use when:** Tasks must execute in order (dependencies)

```
Main Agent:
1. Create session context file
2. Execute or delegate Task 1
3. Wait for Task 1 completion
4. Update context with Task 1 results
5. Execute or delegate Task 2 (uses Task 1 results)
6. Continue until all tasks complete

Context file: Single shared file, updated after each task
```

**Example: Plan → Implement → Review**
```
1. Planning Agent (main):
   - Creates session_context_plan_<id>.md
   - Generates task plan
   - Updates context with planning results

2. Implementation Agent (main):
   - Reads session_context_plan_<id>.md
   - Creates session_context_implement_<id>.md
   - Links to planning context
   - Implements based on plan
   - Updates both contexts

3. Review Agent (pr-reviewer):
   - Reads session_context_implement_<id>.md
   - Reviews implementation
   - Updates context with review findings
```

### Pattern 2: Parallel Delegation

**Use when:** Independent tasks with no dependencies

```
Main Agent:
1. Create main session context file
2. Identify independent sub-tasks
3. Create context file for each sub-task
4. Dispatch all agents in PARALLEL (single message, multiple Task calls)
5. Wait for all agents to complete
6. Synthesize results from all context files
7. Update main context file

Context files: One per sub-task + one main coordination file
```

**Example: Parallel Bug Fixes**
```
Main Agent:
- Creates: session_context_main_<id>.md
- Creates: session_context_bug1_<id>.md
- Creates: session_context_bug2_<id>.md
- Creates: session_context_bug3_<id>.md

Parallel dispatch (single message):
Task(prompt="Context file: tasks/session_context_bug1_<id>.md. Fix bug #1")
Task(prompt="Context file: tasks/session_context_bug2_<id>.md. Fix bug #2")
Task(prompt="Context file: tasks/session_context_bug3_<id>.md. Fix bug #3")

Wait for all → Read all contexts → Synthesize results
```

### Pattern 3: Hierarchical Delegation

**Use when:** Task has sub-tasks, and sub-tasks have their own sub-tasks

```
Main Agent (Coordinator):
1. Create coordination context
2. Break down into major phases
3. Delegate each phase to specialized agent

Specialized Agent (Phase Owner):
1. Read coordination context
2. Create phase-specific context
3. Break down phase into sub-tasks
4. Execute or further delegate sub-tasks
5. Update phase context
6. Return to coordinator

Coordinator:
1. Read phase context
2. Update coordination context
3. Proceed to next phase
```

## Agent Invocation

### Using Task Tool

**Single agent invocation:**
```
Task(
  subagent_type: "pr-reviewer",
  description: "Review OAuth implementation PR",
  prompt: """
Context file: tasks/session_context_implement_20251122_150530_98765.md

Review the OAuth implementation PR. The implementation added:
- JWT token generation with 15-min expiry
- GitHub and Google OAuth providers
- Refresh token functionality

Check for security issues, code quality, and test coverage.
"""
)
```

**Parallel agent invocations (CRITICAL: single message):**
```
# In ONE message, invoke multiple agents:

Task(
  subagent_type: "general-purpose",
  description: "Fix test file A failures",
  prompt: "Context file: tasks/session_context_bugfix_a_<id>.md. [details]"
)

Task(
  subagent_type: "general-purpose",
  description: "Fix test file B failures",
  prompt: "Context file: tasks/session_context_bugfix_b_<id>.md. [details]"
)

Task(
  subagent_type: "general-purpose",
  description: "Fix test file C failures",
  prompt: "Context file: tasks/session_context_bugfix_c_<id>.md. [details]"
)
```

### Agent Prompt Structure

**Good agent prompts:**
1. **Context file path** - First line, always
2. **Clear objective** - What should agent accomplish?
3. **Specific instructions** - How to approach the task
4. **Expected output** - What should agent return?
5. **Constraints** - What to avoid, boundaries

**Example:**
```
Context file: tasks/session_context_issue_20251122_153045_44444.md

Create GitHub issue from the task plan at tasks/user_auth_oauth2_20251122_143022_12345.md.

The issue should:
1. Have a clear title summarizing the feature
2. Include all subtasks as checklist items
3. Reference technical decisions from context file
4. Add appropriate labels (feature, enhancement)

Expected output: GitHub issue URL and issue number.
```

**Bad agent prompts:**
```
# ❌ Missing context file path
Create an issue for the OAuth feature.

# ❌ Vague objective
Do something with the PR.

# ❌ No expected output
Review the code.
```

## Monitoring Agent Execution

### During Execution

Agents report back through:
- **Tool results** - Immediate feedback on tool execution
- **Final summary** - Agent's report of work completed
- **Context file updates** - Agent's recorded actions and decisions

**What to monitor:**
- Agent understanding of objective (from initial actions)
- Progress toward goal (from activity log updates)
- Blockers or issues (from context file Blockers section)
- Quality of output (from final summary)

### After Completion

**Read agent's context updates:**
```
Read(file_path: "tasks/session_context_<agent_session_id>.md")
```

**Extract:**
- Actions taken (Activity Log)
- Decisions made (Technical Decisions)
- Issues encountered (Blockers)
- Results achieved (Current State, Quality Gates)

**Verify:**
- Did agent complete objective?
- Are results acceptable?
- Were there unresolved blockers?
- Is context file properly updated?

## Result Synthesis

### Single Agent Result

After agent completes:

1. **Read agent's context file**
2. **Extract key information:**
   - What was accomplished
   - What decisions were made
   - What issues were encountered
   - What files were changed
3. **Update main context file** (if applicable)
4. **Proceed with next step** or **complete workflow**

### Multiple Agent Results (Parallel)

After all agents complete:

1. **Read all agent context files**
2. **Check for conflicts:**
   - Did agents modify same files?
   - Are decisions contradictory?
   - Are there overlapping changes?
3. **Synthesize findings:**
   - Combine successful outcomes
   - Identify failures or incomplete work
   - Note patterns across agents
4. **Update main context file:**
   - Summary of all agent work
   - Consolidated decisions
   - Overall status
5. **Resolve conflicts** if needed
6. **Verify integration** (run tests, check builds)

**Example synthesis:**
```markdown
## Agent Results Summary

### Bug Fix Agent 1 (auth.spec.ts)
- Status: Completed
- Tests fixed: 3/3
- Approach: Replaced timeouts with event-based waiting
- Files changed: src/auth/auth.spec.ts

### Bug Fix Agent 2 (user.spec.ts)
- Status: Completed
- Tests fixed: 2/2
- Approach: Fixed mock structure (threadId placement)
- Files changed: src/user/user.spec.ts

### Bug Fix Agent 3 (oauth.spec.ts)
- Status: Completed with caveat
- Tests fixed: 1/1
- Approach: Added async wait for tool execution
- Files changed: src/oauth/oauth.spec.ts
- Note: Required additional dependency (wait-for-expect)

### Integration
- No file conflicts detected
- All agents' changes are compatible
- Full test suite: 48/48 passing
- Linting: Clean
```

## Error Handling

### Agent Fails to Complete

**If agent reports failure:**
1. Read agent's context file for details
2. Check Blockers section for root cause
3. Decide:
   - **Retry** with additional guidance
   - **Fix issue manually** then re-delegate
   - **Route to different agent** if wrong specialization
   - **Escalate to user** if unrecoverable

### Agent Produces Incorrect Results

**If agent's output is wrong:**
1. Read agent's context for understanding
2. Identify where agent went wrong
3. Create new context file with:
   - Corrective guidance
   - Specific constraints
   - Examples of correct approach
4. Re-delegate with improved instructions

### Agents Have Conflicts (Parallel)

**If parallel agents conflict:**
1. Identify conflict type:
   - Same file modifications
   - Contradictory decisions
   - Incompatible approaches
2. Read all relevant contexts
3. Resolve manually or delegate to resolution agent
4. Update contexts with resolution
5. Verify integration

## Common Patterns

### Pattern: Code Review After Implementation

```
1. Implementation completes
2. Get git commit SHAs (before/after)
3. Create review context file
4. Delegate to pr-reviewer:
   - Context file path
   - BASE_SHA and HEAD_SHA
   - What was implemented
   - Plan or requirements reference

5. Review completes
6. Read review context
7. If issues found:
   - Create fix context
   - Delegate fixes
   - Re-review
8. If issues clear:
   - Proceed to next phase
```

### Pattern: Planning with Multiple Explorations

```
1. Create planning context
2. Identify areas needing exploration:
   - Existing patterns
   - Similar implementations
   - Technical constraints

3. Dispatch parallel explorers:
   Task(explore authentication patterns)
   Task(explore OAuth libraries)
   Task(explore testing strategies)

4. All explorers complete
5. Read all exploration contexts
6. Synthesize findings into planning context
7. Generate final plan with enriched context
```

### Pattern: Issue Creation from Planning

```
1. Planning phase completes
2. Create issue-writing context
3. Link to planning context and task doc
4. Delegate to issue-writer:
   - Context file with planning results
   - Task documentation file path
   - Requirements and acceptance criteria

5. Issue writer completes
6. Read issue context
7. Verify issue created correctly
8. Update planning context with issue URL
```

## Agent Specializations

### pr-reviewer Agent

**When to use:** After code implementation, before merging

**Context requirements:**
- What was implemented
- Plan or requirements reference
- Git commit range (BASE_SHA to HEAD_SHA)

**Expected output:**
- Strengths identified
- Issues categorized (Critical/Important/Minor)
- Assessment (Ready/Needs work)

### issue-writer Agent

**When to use:** Converting plans to GitHub issues

**Context requirements:**
- Task plan document
- Objective and scope
- Acceptance criteria

**Expected output:**
- GitHub issue URL
- Issue number
- Issue content preview

### pr-checker Agent

**When to use:** Monitoring and fixing PR checks

**Context requirements:**
- PR URL or PR number
- Repository context
- Expected checks

**Expected output:**
- Check status summary
- Failures identified
- Fixes applied (if auto-fixable)

### prompt-engineer Agent

**When to use:** Optimizing agent prompts for better results

**Context requirements:**
- Current prompt
- Desired outcome
- Issues with current prompt

**Expected output:**
- Optimized prompt
- Explanation of improvements
- Testing recommendations

## Quality Standards

**Before delegating:**
- [ ] Context file created with unique session ID
- [ ] Objective clearly stated in context
- [ ] Agent prompt starts with "Context file: <path>"
- [ ] Agent responsibilities are clear
- [ ] Expected output is specified

**During execution:**
- [ ] Monitor agent progress through context updates
- [ ] Watch for blockers in agent's context
- [ ] Verify agent understands objective

**After completion:**
- [ ] Read agent's updated context file
- [ ] Verify objective was met
- [ ] Check for unresolved blockers
- [ ] Synthesize results if multiple agents
- [ ] Update main context with agent outcomes

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Delegating without context file | Always create context file first |
| Missing "Context file:" in prompt | Start every context-sharing agent prompt with path |
| Not reading agent's context after | Always read to verify completion and extract results |
| Parallel delegation in separate messages | Use single message with multiple Task calls |
| Vague agent instructions | Specify objective, approach, and expected output |
| Not monitoring agent progress | Check context file updates during execution |
| Ignoring agent's blockers | Read Blockers section and address issues |

## Integration with Skills

- **context-file-management** - REQUIRED: Proper context file creation and updates
- **subagent-driven-development** - Uses agent coordination for task execution
- **dispatching-parallel-agents** - Specialized pattern for parallel bug fixes
- **verification-before-completion** - Verify agent results before claiming success

## Quick Reference

### Delegation Checklist

1. **Identify** task type and appropriate agent (CLAUDE.md table)
2. **Create** session context file (unique session ID)
3. **Initialize** context with objective and workflow info
4. **Prepare** agent prompt starting with "Context file: <path>"
5. **Specify** clear objective, instructions, expected output
6. **Invoke** using Task tool (parallel if multiple agents)
7. **Monitor** through context file updates
8. **Read** agent's context after completion
9. **Verify** objective met and results acceptable
10. **Synthesize** if multiple agents
11. **Update** main context with outcomes
12. **Proceed** to next workflow step

### Context Sharing Quick Reference

**Context file path format:**
```
tasks/session_context_<workflow>_<timestamp>_<random>.md
```

**Agent prompt template:**
```
Context file: tasks/session_context_<session_id>.md

<Clear objective>

<Specific instructions>

<Expected output>

<Constraints or notes>
```

**After agent completion:**
```
1. Read: tasks/session_context_<agent_session_id>.md
2. Extract: Activity Log, Technical Decisions, Blockers, Results
3. Verify: Objective met, quality acceptable
4. Update: Main context if applicable
```

## Real-World Impact

**With proper coordination:**
- Specialized agents handle appropriate tasks
- Context is preserved across agent boundaries
- Multiple agents work efficiently in parallel
- Results are properly synthesized
- Workflow progress is traceable

**Without proper coordination:**
- Tasks routed to wrong agents
- Context lost between agents
- Agents work sequentially when could parallelize
- Results are fragmented or conflicting
- Workflow state is unclear
