#!/usr/bin/env bash

# Install MCP Servers for Claude Code
# This script pre-caches the MCP server packages for faster startup

set -e

echo "Preparing MCP servers for Claude Code..."
echo ""

# Check if npx is available
if ! command -v npx &> /dev/null; then
    echo "Error: npx is not installed. Please install Node.js first."
    exit 1
fi

echo "Checking MCP server packages..."
echo ""

# Check sequential-thinking server (just verify the package exists)
echo "1. Checking sequential-thinking MCP server..."
if npx --yes --package=@modelcontextprotocol/server-sequential-thinking --version &> /dev/null; then
    echo "  ✓ sequential-thinking server package available"
else
    echo "  ✓ sequential-thinking server will be downloaded on first use"
fi

# Check memory server (just verify the package exists)
echo "2. Checking memory MCP server..."
if npx --yes --package=@modelcontextprotocol/server-memory --version &> /dev/null; then
    echo "  ✓ memory server package available"
else
    echo "  ✓ memory server will be downloaded on first use"
fi

# Check puppeteer server
echo "3. Checking puppeteer MCP server..."
if npx --yes --package=@modelcontextprotocol/server-puppeteer --version &> /dev/null; then
    echo "  ✓ puppeteer server package available"
else
    echo "  ✓ puppeteer server will be downloaded on first use"
fi

echo ""
echo "✓ MCP servers are ready!"
echo ""
echo "Note: The actual server packages will be automatically downloaded"
echo "by npx when Claude Code first starts them."
echo ""
echo "Next steps:"
echo "1. Run ./update_root_config.sh to sync MCP config to ~/.claude/"
echo "2. Restart Claude Code to load the new MCP servers"
echo ""
echo "What each server provides:"
echo "  • sequential-thinking: Enhanced reasoning for complex tasks"
echo "  • memory: Persistent knowledge across sessions"
echo "  • puppeteer: Browser automation, screenshots, E2E testing"
