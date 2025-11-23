#!/bin/bash
# Session start hook - reads README.md into context

README_PATH="README.md"

if [ -f "$README_PATH" ]; then
    echo "📖 Project Guidelines from README.md:"
    echo ""
    cat "$README_PATH"
    echo ""
    echo "---"
    echo "✅ Please follow the development workflow outlined above."
else
    echo "⚠️  README.md not found at $README_PATH"
fi
