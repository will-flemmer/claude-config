#!/bin/bash

set -e

echo "Syncing Claude Code configuration to ~/.claude/..."
echo ""

# Create directories
mkdir -p ~/.claude
mkdir -p ~/.claude/commands
mkdir -p ~/.claude/agents
mkdir -p ~/.claude/skills

# Copy CLAUDE.md
cp CLAUDE.md ~/.claude/
echo "✓ Copied CLAUDE.md to ~/.claude/"

# Copy commands if directory exists
if [ -d commands ]; then
    cp -r commands/* ~/.claude/commands/
    echo "✓ Copied commands to ~/.claude/commands/"
fi

# Copy agents if directory exists
if [ -d agents ]; then
    cp -r agents/* ~/.claude/agents/
    echo "✓ Copied agents to ~/.claude/agents/"
fi

# Copy skills if directory exists
if [ -d skills ]; then
    cp -r skills/* ~/.claude/skills/
    echo "✓ Copied skills to ~/.claude/skills/"
fi

# Copy MCP config
if [ -f .mcp.json ]; then
    cp .mcp.json ~/.claude/
    echo "✓ Copied .mcp.json to ~/.claude/"
fi

# Copy global settings
if [ -f settings.json ]; then
    cp settings.json ~/.claude/
    echo "✓ Copied settings.json to ~/.claude/"
fi

echo ""
echo "Configuration sync complete!"
echo ""
echo "Note: You need to restart Claude Code for changes to take effect."