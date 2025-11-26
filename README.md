# Claude Code Configuration

Personal Claude Code configuration with custom commands, skills, and persistent memory system.

## Quick Start

```bash
# 1. Install MCP servers (sequential-thinking, memory, puppeteer)
./install-mcp-servers.sh

# 2. Sync configuration to ~/.claude/
./update_root_config.sh

# 3. Setup MCP in your project
cd /path/to/your/project
cp ~/.claude/.mcp.json .

# Or use the setup script
/path/to/claude-config/setup-project-mcp.sh

# 4. Start Claude in your project
claude

# 5. Initialize memory (in Claude Code)
/init-memory
```

## What's Included

**Commands:**
- `/plan-task` - Plan tasks with memory context
- `/implement-plan` - TDD implementation with automatic learning storage
- `/init-memory` - Initialize persistent memory system
- `/pr-checks` - Monitor PR checks

**Features:**
- Persistent memory across sessions (remembers decisions, patterns, bugs)
- Skills for workflow automation (TDD, verification, parallel execution)
- Parallel execution optimization

## Daily Usage

```bash
# Memory is automatic - just use your commands
/plan-task "Add feature"      # Queries past context
/implement-plan tasks/...      # Stores learnings
```

## Setup MCP in New Projects

Each project needs its own `.mcp.json`:

```bash
# Easy way - use the setup script
cd /path/to/your/project
/path/to/claude-config/setup-project-mcp.sh

# Or manually copy
cp /path/to/claude-config/.mcp.json .
```

## Sync Changes

After editing this repo:

```bash
./update_root_config.sh       # Sync to ~/.claude/
```

Update existing projects' `.mcp.json` manually if you change MCP config.
