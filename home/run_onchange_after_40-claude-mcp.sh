#!/bin/bash
# MCP servers for Claude Code (user scope, so every project sees them).
set -euo pipefail
command -v claude >/dev/null || { echo "Claude Code not installed, skipping MCP servers"; exit 0; }

# FreeCAD: needs FreeCAD open (the addon auto-starts its server on 127.0.0.1:9875).
if ! claude mcp get freecad >/dev/null 2>&1; then
  claude mcp add --scope user freecad -- uvx freecad-mcp@latest
fi
