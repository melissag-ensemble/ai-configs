#!/bin/bash
# Syncs mcpServers from Claude Desktop config into ~/.claude.json (Claude Code / VS Code extension).
set -euo pipefail

DESKTOP_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
CLAUDE_CODE_CONFIG="$HOME/.claude.json"

if [ ! -f "$DESKTOP_CONFIG" ]; then
  echo "ERROR: Claude Desktop config not found: $DESKTOP_CONFIG" >&2
  exit 1
fi

if [ ! -f "$CLAUDE_CODE_CONFIG" ]; then
  echo "ERROR: Claude Code config not found: $CLAUDE_CODE_CONFIG" >&2
  exit 1
fi

python3 - "$DESKTOP_CONFIG" "$CLAUDE_CODE_CONFIG" <<'PYEOF'
import json, sys

desktop_path, code_path = sys.argv[1], sys.argv[2]

with open(desktop_path) as f:
    desktop = json.load(f)

with open(code_path) as f:
    code = json.load(f)

desktop_servers = desktop.get("mcpServers", {})
if not desktop_servers:
    print("No mcpServers found in Desktop config — nothing to sync.")
    sys.exit(0)

before = set(code.get("mcpServers", {}).keys())

# Merge Desktop servers in; add 'type: stdio' expected by Claude Code
for name, cfg in desktop_servers.items():
    entry = dict(cfg)
    entry.setdefault("type", "stdio")
    code.setdefault("mcpServers", {})[name] = entry

after = set(code["mcpServers"].keys())
added = after - before
unchanged = before & after

with open(code_path, "w") as f:
    json.dump(code, f, indent=2)

if added:
    print(f"Added: {', '.join(sorted(added))}")
if unchanged:
    print(f"Updated: {', '.join(sorted(unchanged))}")
print("Sync complete.")
PYEOF
