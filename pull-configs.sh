#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Pulling ai-configs (CLAUDE.md, AGENTS.md)..."
cd "$SCRIPT_DIR"
git pull origin main

echo "==> Pulling cursor rules (adp-devsite-cursor-rules)..."
cd "$SCRIPT_DIR/adp-devsite-cursor-rules"
git pull

echo "==> Checking .cursor symlink..."
SYMLINK="$SCRIPT_DIR/.cursor"
TARGET="$SCRIPT_DIR/adp-devsite-cursor-rules/.cursor"
if [ ! -L "$SYMLINK" ]; then
  echo "    Symlink missing — creating it..."
  rm -rf "$SYMLINK"
  ln -s "$TARGET" "$SYMLINK"
  echo "    Created: .cursor -> $TARGET"
else
  echo "    Symlink OK."
fi

echo "==> Checking .claude/commands symlink..."
CLAUDE_CMD_SYMLINK="$SCRIPT_DIR/.claude/commands"
CLAUDE_CMD_TARGET="$SCRIPT_DIR/adp-devsite-cursor-rules/.claude/commands"
mkdir -p "$SCRIPT_DIR/.claude"
if [ ! -L "$CLAUDE_CMD_SYMLINK" ]; then
  echo "    Symlink missing — creating it..."
  rm -rf "$CLAUDE_CMD_SYMLINK"
  ln -s "$CLAUDE_CMD_TARGET" "$CLAUDE_CMD_SYMLINK"
  echo "    Created: .claude/commands -> $CLAUDE_CMD_TARGET"
else
  echo "    Symlink OK."
fi

echo "==> Codex AGENTS.md refresh"
echo "    If CLAUDE.md changed, run: ./refresh-agents.sh"

echo ""
echo "Done."
