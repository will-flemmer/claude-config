#!/bin/bash

mkdir -p ~/.claude
cp CLAUDE.md ~/.claude/

# Copy commands if directory exists
if [ -d commands ]; then
    mkdir -p ~/.claude/commands
    cp -r commands/* ~/.claude/commands/
fi