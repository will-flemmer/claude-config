# Agent-First Development Guidelines

## Core Principle: Agent-First Task Execution

**MANDATORY**: ALWAYS use specialized agents via Task tool for ALL implementation, analysis, or specialized work. Never attempt complex tasks directly.

### Agent Routing

| Task Type | Agent | Context Required |
|-----------|-------|------------------|
| Code implementation | language-specific agents | Yes* |
| Code review/quality | pr-reviewer | Yes* |
| PR management | pr-checker | Yes* |
| Issue creation | issue-writer | Yes* |
| Task planning | task-decomposition-expert | Yes* |
| Command creation | command-writer | No |
| Prompt optimization | prompt-engineer | Yes* |

*Context-sharing agents MUST use session files at `tasks/session_context_<id>.md`

**CRITICAL**: Every context-sharing agent invocation MUST start prompt with: `"Context file: path/to/context.md. [task instructions]"`

### Task Routing Process
1. **Identify Task Type**: Determine which specialized agent is most appropriate
2. **Create Context File**: For context-sharing agents, create session context file first
3. **Use Task Tool**: Always use `Task(subagent_type: "agent-name", description: "brief", prompt: "Context file: path/to/context.md. [detailed task]")`
4. **Pass Context Path**: MANDATORY - Include context file path at start of every agent prompt
5. **Monitor Progress**: Let agents complete their specialized work

### Direct Task Exceptions
Only handle directly:
- Basic git status checks
- Immediate clarifications
- Agent coordination/routing

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
# Multi-agent workflow with context
session_id="issue_$(date +%Y%m%d_%H%M%S)_$RANDOM"
context_file="tasks/session_context_${session_id}.md"

# MANDATORY: Always start prompt with context file path
Task(subagent_type="task-decomposition-expert", 
     prompt="Context file: ${context_file}. Analyze the following task for complexity and break it down into actionable components.")

# Next agent also gets context file path
Task(subagent_type="issue-writer", 
     prompt="Context file: ${context_file}. Create GitHub issue based on task analysis from previous agent.")
```

See `context-sharing-guide.md` for implementation details.

## Quality Standards (For Agents)

Agents must follow:
- **TDD**: RED → GREEN → REFACTOR cycles
- **Simplicity**: Simplest solution that works
- **DRY**: No code duplication
- **Testing**: 100% coverage target
- **Linting**: Use `just lint` command

## Task Completion Checklist

Before marking complete:
1. ✓ Agent completed work
2. ✓ Tests pass (`just test`)
3. ✓ Linting passes (`just lint`)
4. ✓ Context updated (if applicable)

## Tool Configuration

### Commands
- Use `Justfile` for project commands
- Scripts location: `~/.claude/commands/<command-name>/`

### Required Tools
- `git`, `gh`, `just`, `jq`