#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Pulling CLAUDE.md (ai-configs)..."
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

echo "Done."
