# Claude Config

This repository contains a versioned copy of my global Claude Code configuration, enabling version control and collaborative development of Claude Code commands and agents.

## Purpose

This repo serves as:
- **Version Control**: Track changes to Claude Code configuration over time
- **Documentation**: Centralized documentation for custom commands and workflows
- **Backup**: Reliable backup of Claude Code customizations

## Syncing with Global Config

Changes made in this repository are copied to the global Claude Code configuration:

```bash
# Copy commands from repo to global config
cp -r commands/* ~/.claude/commands/

# Copy CLAUDE.md instructions
cp CLAUDE.md ~/.claude/CLAUDE.md

# Copy other config files as needed
```

## Structure

```
.
├── CLAUDE.md                    # Agent-First Development Guidelines
├── commands/                    # Custom slash commands
│   ├── plan-task/              # Task planning command
│   ├── implement-plan/         # Implementation command
│   └── ...
├── tasks/                      # Generated task plans and session contexts
└── README.md                   # This file
```

## Key Features

### Custom Commands

- **plan-task**: Intelligently plan and decompose tasks with parallel execution
- **implement-plan**: Execute planned tasks with proper context sharing
- **pr-checks**: Monitor and analyze GitHub PR checks
- **create-gh-issue**: Generate comprehensive GitHub issues

### Agent-First Architecture

This configuration follows an agent-first approach where:
- Complex tasks are routed to specialized agents
- Context is shared via session files in `tasks/`
- Main Claude agent handles direct tasks like planning
- Specialized agents handle review, PR management, issue creation

## Usage

Commands are available globally after syncing:

```bash
# Use commands in any project
cd ~/any-project
/plan-task "Add new feature"
/implement-plan tasks/feature_plan_<session_id>.md
```

## Contributing

When making changes:

1. **Edit**: Make changes to command documentation or configuration files
2. **Document**: Update relevant documentation (CLAUDE.md, command docs)
3. **Sync**: Copy to global config using the sync commands above
4. **Commit**: Version control all changes

## Configuration Philosophy

- **Planning-Only Commands**: Commands like `plan-task` only create plans, never implement
- **Parallel Execution**: Optimize performance with parallel tool calls
- **Context Sharing**: Enable multi-agent coordination via session files
- **Clear Boundaries**: Explicit separation between planning and implementation

## References

- [Claude Code Documentation](https://docs.claude.com/en/docs/claude-code/)
- Global config location: `~/.claude/`
- Session contexts: `tasks/session_context_*.md`
- Task plans: `tasks/*_<session_id>.md`
