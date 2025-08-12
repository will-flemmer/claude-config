#!/bin/bash

mkdir -p ~/.claude
cp CLAUDE.md ~/.claude/

# Copy commands if directory exists
if [ -d commands ]; then
    mkdir -p ~/.claude/commands
    mkdir -p ~/.claude/agents
    cp -r commands/* ~/.claude/commands/
    cp -r agents/* ~/.claude/agents/
fi
echo "Copied config CLAUDE.MD to ~/.claude/CLAUDE.MD"
echo "Copied commands into ~/.claude/commands/"
echo "Copied agents into ~/.claude/agents/"