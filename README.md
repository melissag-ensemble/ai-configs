# ai-configs

Personal AI assistant configs shared across every repo under `~/Projects/`:

- `CLAUDE.md` — Claude Code
- `AGENTS.md` — Codex
- a `.cursor` symlink — Cursor rules
- a `.claude/commands` symlink — Claude Code slash commands

## What lives where

| Path | Tool | Purpose |
|---|---|---|
| `CLAUDE.md` | Claude Code + Cursor | Source of truth — personal preferences + workspace knowledge |
| `AGENTS.md` | Codex + Cursor | Codex-friendly version derived from `CLAUDE.md` |
| `adp-devsite-cursor-rules/.cursor/rules/eds-conversion.mdc` | Cursor | Gatsby-to-EDS conversion workflow rule |
| `adp-devsite-cursor-rules/.claude/commands/devsite-release.md` | Claude Code | `/devsite-release` slash command — builds the `adp-devsite` Release PR description and logs release notes to `dev-docs-reference` |
| `pull-configs.sh` | — | Pulls latest configs + cursor rules and ensures the `.cursor` and `.claude/commands` symlinks exist |
| `refresh-agents.sh` | Codex | Prints/copies a Codex prompt to regenerate `AGENTS.md` from `CLAUDE.md` |
| `sync-claude-mcp.sh` | Claude Desktop → Claude Code | Syncs MCP servers from Desktop config to `~/.claude.json` |

`CLAUDE.md` and `AGENTS.md` are scoped to `~/Projects/` so Claude Code and Codex pick them up across all child repos automatically. Cursor also auto-imports them via the "Include third-party Plugins, Skills, and other configs" setting.

The `.cursor` and `.claude/commands` symlinks both point into the sibling `adp-devsite-cursor-rules` repo, so its rules and slash commands are shared into `~/Projects/` without duplicating files. Each symlinks a whole directory, so anything added under `adp-devsite-cursor-rules/.cursor/rules/` or `.claude/commands/` is picked up automatically — no per-file wiring.

## Setup

### CLAUDE.md and AGENTS.md

This repo lives directly at `~/Projects/`. The `CLAUDE.md` and `AGENTS.md` at the root are picked up automatically by Claude Code and Codex for any repo opened inside `~/Projects/`.

### Cursor rules + Claude commands

Clone the cursor rules repo into `~/Projects/` (sibling to this repo's root):

```bash
cd ~/Projects
git clone https://github.com/AdobeDocs/adp-devsite-cursor-rules
```

Then run `./pull-configs.sh` to create/verify the `.cursor` and `.claude/commands` symlinks.

## Claude Code slash commands

Slash commands live in `adp-devsite-cursor-rules/.claude/commands/` and are exposed at `~/Projects/.claude/commands/` via the symlink, so they're available in any repo opened under `~/Projects/`.

- `/devsite-release` — compares `AdobeDocs/adp-devsite` `stage` vs `main`, builds a Release PR description (PRs, Jira tickets, approvers), and opens/updates a release-notes PR in `AdobeDocs/dev-docs-reference`.

To add a new command: drop a `.md` file in `adp-devsite-cursor-rules/.claude/commands/`, commit it there, and it's instantly available — no `pull-configs.sh` change needed (the symlink covers the whole directory).

## Personal Preferences

Both `CLAUDE.md` and `AGENTS.md` include a **Personal Preferences** section at the top. This section controls response style and formatting (tone, bullet structure, link format, table icons, etc.) and applies to all repos under `~/Projects/`. Cursor inherits these via the auto-import of `CLAUDE.md` / `AGENTS.md`.

**To update preferences:**
1. Edit the `Personal Preferences` section in `CLAUDE.md` — this is the source of truth
2. Update the same section in `AGENTS.md` to match (or run `./refresh-agents.sh` and paste the Codex prompt)
3. Commit

## Usage

```bash
./pull-configs.sh
```

Pulls the latest `ai-configs` and cursor rules, and ensures the `.cursor` and `.claude/commands` symlinks are set up.

If `CLAUDE.md` changed and you want to refresh the Codex version:

```bash
./refresh-agents.sh
```

Prints a ready-to-paste Codex prompt and copies it to your clipboard. The prompt tells Codex to update `AGENTS.md` from `CLAUDE.md`, preserving the Personal Preferences section verbatim and keeping the workspace context concise.

## Sync

1. `cd ~/Projects`
2. `./pull-configs.sh` — pull `ai-configs` and cursor rules, verify the `.cursor` and `.claude/commands` symlinks
3. If `CLAUDE.md` changed: `./refresh-agents.sh` → paste into Codex → review diff → commit
4. If personal preferences changed: manually update the `Personal Preferences` section in `AGENTS.md` to match `CLAUDE.md`

### MCP server sync (Claude Desktop ↔ Claude Code)

`sync-claude-mcp.sh` merges `mcpServers` from Claude Desktop's config into `~/.claude.json` so both tools stay in sync automatically.

**How it works:** A launchd agent (`com.melissag.sync-claude-mcp`) watches the Desktop config file and runs the script whenever it changes. It also runs once at login.

**First-time setup** (one-time, already done on this machine):
```bash
launchctl load ~/Library/LaunchAgents/com.melissag.sync-claude-mcp.plist
```

**On a new machine:**
```bash
cp ~/Projects/sync-claude-mcp.sh ~/Projects/  # already in repo
# Create the plist at ~/Library/LaunchAgents/com.melissag.sync-claude-mcp.plist (see com.melissag.sync-claude-mcp.plist in repo)
launchctl load ~/Library/LaunchAgents/com.melissag.sync-claude-mcp.plist
```

**Logs:** `~/Library/Logs/sync-claude-mcp.log`

**Manual run:** `./sync-claude-mcp.sh`
