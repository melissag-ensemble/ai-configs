#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_FILE="$SCRIPT_DIR/CLAUDE.md"
AGENTS_FILE="$SCRIPT_DIR/AGENTS.md"

if [ ! -f "$CLAUDE_FILE" ]; then
  echo "Missing source file: $CLAUDE_FILE" >&2
  exit 1
fi

if [ ! -f "$AGENTS_FILE" ]; then
  echo "Missing target file: $AGENTS_FILE" >&2
  exit 1
fi

PROMPT=$(cat <<EOF
Update $AGENTS_FILE from $CLAUDE_FILE.

Treat CLAUDE.md as the source of truth, but do not copy it 1:1.
Rewrite AGENTS.md for Codex as a concise workspace-context file for repos under /Users/melissag/Projects.

Keep:
- the entire "Personal Preferences" section verbatim — do not condense or reword it
- durable institutional knowledge
- cross-repo mental models
- architecture facts
- environment, routing, deployment, and local-dev heuristics
- known traps and "check X before Y" guidance

Remove or condense:
- long reference links
- duplicated examples
- verbose prose that is not useful as persistent working context
- anything task-specific or fast-changing

Preserve the current AGENTS.md style:
- short headings
- compact bullets
- optimized for fast scanning by Codex

After updating AGENTS.md, give me a short summary of what changed and call out anything in CLAUDE.md that seems too detailed to belong in AGENTS.md.
EOF
)

echo "==> Codex prompt"
echo
echo "$PROMPT"
echo

if command -v pbcopy >/dev/null 2>&1; then
  printf "%s" "$PROMPT" | pbcopy
  echo "Copied prompt to clipboard."
else
  echo "pbcopy not found; prompt not copied."
fi

echo
echo "Suggested workflow:"
echo "1. Run ./pull-configs.sh"
echo "2. Run ./refresh-agents.sh"
echo "3. Paste the copied prompt into Codex while /Users/melissag/Projects is open"
