# Skills & Agent-First Development Guidelines

## ⚡ SKILL INVOCATION CHECKLIST - CHECK ON EVERY REQUEST ⚡

Skills require **manual invocation** using `Skill({ skill: "skill-name" })`. Check this list on EVERY user request:

### Mandatory Checks (Do These First)

1. **Is this the first substantial request in the session?**
   - ✅ YES → Invoke `Skill({ skill: "query-decision" })`
   - ❌ NO → Continue to next check

2. **Am I about to read/search 2+ files or patterns?**
   - ✅ YES → Invoke `Skill({ skill: "parallel-execution-patterns" })`
   - ❌ NO → Continue to next check

3. **Am I about to claim work is complete/fixed/passing?**
   - ✅ YES → Invoke `Skill({ skill: "verification-before-completion" })`
   - ❌ NO → Continue to next check

### Context-Specific Checks

4. **Planning a feature or making architectural decisions?**
   - ✅ YES → Invoke `Skill({ skill: "memory-driven-planning" })`

5. **Working with unit tests in any way?** (reading, writing, updating, planning, evaluating, reviewing)
   - ✅ YES → Invoke `Skill({ skill: "unit-testing" })`

6. **Implementing a planned task with subtasks?**
   - ✅ YES → Invoke `Skill({ skill: "subagent-driven-development" })`

7. **Need to coordinate multiple specialized agents?**
   - ✅ YES → Invoke `Skill({ skill: "agent-coordination" })`

**REMEMBER:** Skills don't auto-run. You must explicitly invoke them!

---

## Quick Reference

**3 Mandatory Skills:**
1. `query-decision` - First substantial request in session
2. `verification-before-completion` - Before claiming work complete
3. `parallel-execution-patterns` - Reading/searching 2+ locations

**Common Workflows:**
- Planning → `memory-driven-planning` skill
- Implementation → `subagent-driven-development` skill
- Testing → `unit-testing` skill
- Multi-agent → `agent-coordination` skill

## Skills Usage (MANDATORY)

**Skills are process automation tools that MUST be used proactively**. Skills orchestrate complex workflows that would otherwise require manual coordination.

### When to Use Skills (Use Aggressively)

| Trigger | Skill | Rationale |
|---------|-------|-----------|
| **EVERY first substantial request** | `query-decision` | Automatically decides if memory query needed |
| Reading 2+ files in parallel | `parallel-execution-patterns` | 5-8x performance boost |
| Multiple grep/glob operations | `parallel-execution-patterns` | Execute all searches simultaneously |
| Planning features/architecture | `memory-driven-planning` | Query memory for patterns, failures, decisions |
| About to claim work complete | `verification-before-completion` | ALWAYS verify before success claims |
| Working with unit tests (any capacity) | `unit-testing` | Apply TDD principles with proper coverage |
| Multi-agent workflows needed | `agent-coordination` | Orchestrate specialized agents with context |
| Managing session context files | `context-file-management` | Track state across agents |
| 3+ independent failures | `dispatching-parallel-agents` | Investigate concurrently |
| Implementing planned tasks | `subagent-driven-development` | Fresh subagent per task with reviews |
| Creating/editing skills | `writing-skills` | TDD for process documentation |

### Critical Skill Rules

1. **ALWAYS use `query-decision` on first substantial request** in a session
2. **ALWAYS use `verification-before-completion`** before claiming work is done
3. **ALWAYS use `parallel-execution-patterns`** when reading/searching 2+ locations
4. **ALWAYS use `memory-driven-planning`** when planning features
5. **ALWAYS use `unit-testing`** when working with unit tests in any capacity (reading, writing, planning, evaluating, reviewing)
6. **NEVER batch read/search operations** - use `parallel-execution-patterns` instead

### Skills vs Agents

- **Skills**: Process automation (how to work), invoked via `Skill` tool
- **Agents**: Domain expertise (what to do), invoked via `Task` tool
- **Use both**: Skills orchestrate agents for complex workflows

### Agent Routing

| Task Type | Agent | Context Required |
|-----------|-------|------------------|
| Code implementation | main Claude agent | Yes* |
| Code review/quality | pr-reviewer | Yes* |
| PR management | pr-checker | Yes* |
| Issue creation | issue-writer | Yes* |
| Task planning (plan-task) | main Claude agent | Yes* |
| Command creation | command-writer | No |
| Prompt optimization | prompt-engineer | Yes* |

*Context-sharing agents MUST use session files at `tasks/session_context_<id>.md`

**CRITICAL**: Every context-sharing agent invocation MUST start prompt with: `"Context file: path/to/context.md. [task instructions]"`

### Task Routing Process
1. **Check Skills First**: Determine if a skill should orchestrate the workflow
2. **Identify Task Type**: Determine which specialized agent is most appropriate
3. **Create Context File**: For context-sharing agents, create session context file first
4. **Use Task Tool**: Always use `Task(subagent_type: "agent-name", description: "brief", prompt: "Context file: path/to/context.md. [detailed task]")`
5. **Pass Context Path**: MANDATORY - Include context file path at start of every agent prompt
6. **Monitor Progress**: Let agents complete their specialized work

### Direct Task Exceptions
Only handle directly:
- Basic git status checks
- Immediate clarifications
- Agent coordination/routing (let skills handle complex orchestration)

## Context Sharing Protocol

**MANDATORY** for all multi-agent workflows:

### Context File Creation
1. **Generate unique session ID**: `<workflow>_$(date +%Y%m%d_%H%M%S)_$RANDOM`
2. **Create context file**: `tasks/session_context_<session_id>.md`
3. **Initialize with objective** and meta information
4. **Pass file path** to ALL agents in sequence

### Agent Integration
For context-sharing agents:
1. Agent reads context on start
2. Agent updates relevant sections on completion
3. Next agent builds on previous findings

### Examples
```bash
# Example 1: Task planning (executed by main agent, no routing)
# Use the /plan-task command which is executed directly by main agent
/plan-task "Add user authentication with OAuth2"

# Example 2: Multi-agent workflow with context (after planning is complete)
session_id="issue_$(date +%Y%m%d_%H%M%S)_$RANDOM"
context_file="tasks/session_context_${session_id}.md"

# Create GitHub issue from planning document
Task(subagent_type="issue-writer",
     prompt="Context file: ${context_file}. Create GitHub issue based on task plan from planning phase.")
```

See `context-sharing-guide.md` for implementation details.

## Workflow Examples (Skills + Agents)

### Example 1: Feature Planning & Implementation
```
1. User: "Add user authentication with OAuth2"
2. Use `query-decision` skill (auto-decides memory query)
3. Use `memory-driven-planning` skill (queries past patterns/failures)
4. Create plan with context file
5. Use `subagent-driven-development` skill (executes with fresh agents)
6. Use `verification-before-completion` skill (verify before claiming done)
```

### Example 2: Code Exploration
```
1. User: "How does error handling work in the API?"
2. Use `parallel-execution-patterns` skill to:
   - Grep for error patterns in multiple locations
   - Read relevant files concurrently
   - Search for exception handling
3. Synthesize findings
```

### Example 3: Bug Investigation
```
1. User: "Tests are failing in 5 different modules"
2. Use `dispatching-parallel-agents` skill
3. Skill spawns 5 concurrent agents to investigate independently
4. Synthesize findings and create unified fix plan
5. Use `verification-before-completion` before claiming fixed
```

### Example 4: Writing Tests
```
1. User: "Add tests for the payment module"
2. Use `query-decision` skill (check memory for test patterns)
3. Use `unit-testing` skill (applies TDD principles)
4. Skill ensures focused coverage, edge cases, state changes
5. Use `verification-before-completion` (run tests before claiming done)
```

## Memory Integration

**USE `query-decision` SKILL**: Let the skill decide whether to query memory automatically.

### When to Use `query-decision` Skill:
- **MANDATORY on first substantial request** in a session
- When unsure if memory query is needed
- Before any significant planning or implementation

### When to Use `memory-driven-planning` Skill:
- Planning new features or significant changes
- Making architectural decisions
- Working with critical systems (auth, payments, security)
- Complex debugging or testing

### Manual Memory Query (Only if skill not applicable):
Use parallel MCP memory calls:
```javascript
const [similar, architecture, patterns, failures] = await Promise.all([
  mcp__memory__search_nodes({ query: "[context] implementation" }),
  mcp__memory__open_nodes({ names: ["ProjectArchitecture", "API:ProjectArchitecture"] }),
  mcp__memory__search_nodes({ query: "[technology] patterns" }),
  mcp__memory__search_nodes({ query: "[context] failed approach" })
]);
```

Apply findings silently - don't announce queries unless results are significant.

## Quality Standards (For Agents)

Agents must follow:
- **TDD**: RED → GREEN → REFACTOR cycles
- **Simplicity**: Simplest solution that works
- **DRY**: No code duplication
- **Testing**: 100% coverage target
- **Linting**: Use `just lint` command

## Task Completion Checklist

**MANDATORY**: Use `verification-before-completion` skill before claiming work is done.

Before marking complete:
1. ✓ **Run `verification-before-completion` skill** (REQUIRED)
2. ✓ Agent completed work
3. ✓ Tests pass (`just test`)
4. ✓ Linting passes (`just lint`)
5. ✓ Context updated (if applicable)
6. ✓ Evidence before assertions (no claims without proof)

## Tool Configuration

### Commands
- Use `Justfile` for project commands
- Scripts location: `~/.claude/commands/<command-name>/`

### Required Tools
- `git`, `gh`, `just`, `jq`