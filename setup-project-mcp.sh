#!/usr/bin/env bash

# Setup MCP servers for a project
# Run this in any project directory to enable memory and sequential-thinking

set -e

if [ ! -f ".mcp.json" ]; then
    echo "Creating .mcp.json in current project..."
    cat > .mcp.json << 'EOF'
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-sequential-thinking"
      ]
    },
    "memory": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-memory"
      ]
    }
  }
}
EOF
    echo "✓ Created .mcp.json"
    echo ""
    echo "Next steps:"
    echo "1. Restart Claude in this project"
    echo "2. Run /init-memory to set up persistent memory"
else
    echo "✓ .mcp.json already exists in this project"
fi
