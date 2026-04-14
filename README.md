# ai-configs

Personal AI assistant configs: `CLAUDE.md` for Claude Code, `AGENTS.md` for Codex, and a `.cursor` symlink for Cursor rules.

## What lives where

| File | Tool | Purpose |
|---|---|---|
| `CLAUDE.md` | Claude Code + Cursor | Source of truth — personal preferences + workspace knowledge |
| `AGENTS.md` | Codex + Cursor | Codex-friendly version derived from `CLAUDE.md` |
| `adp-devsite-cursor-rules/.cursor/rules/eds-conversion.mdc` | Cursor | Gatsby-to-EDS conversion workflow rule |

`CLAUDE.md` and `AGENTS.md` are scoped to `~/Projects/` so Claude Code and Codex pick them up across all child repos automatically. Cursor also auto-imports them via the "Include third-party Plugins, Skills, and other configs" setting.

## Setup

### CLAUDE.md and AGENTS.md

This repo lives directly at `~/Projects/`. The `CLAUDE.md` and `AGENTS.md` at the root are picked up automatically by Claude Code and Codex for any repo opened inside `~/Projects/`.

### Cursor rules

Clone the cursor rules repo into `~/Projects/` (sibling to this repo's root):

```bash
cd ~/Projects
git clone https://github.com/AdobeDocs/adp-devsite-cursor-rules
```

Then run `./pull-configs.sh` to ensure the `.cursor` symlink is set up.

## Personal Preferences

Both `CLAUDE.md` and `AGENTS.md` include a **Personal Preferences** section at the top. This section controls response style and formatting (tone, bullet structure, link format, table icons, etc.) and applies to all repos under `~/Projects/`.

The Cursor equivalent lives in `adp-devsite-cursor-rules/.cursor/rules/personal-preferences.mdc` with `alwaysApply: true`.

**To update preferences:**
1. Edit the `Personal Preferences` section in `CLAUDE.md` — this is the source of truth
2. Update the same section in `AGENTS.md` to match (or run `./refresh-agents.sh` and paste the Codex prompt)
3. Commit

## Usage

```bash
./pull-configs.sh
```

Pulls the latest `CLAUDE.md` and cursor rules, and ensures the `.cursor` symlink is set up.

If `CLAUDE.md` changed and you want to refresh the Codex version:

```bash
./refresh-agents.sh
```

Prints a ready-to-paste Codex prompt and copies it to your clipboard. The prompt tells Codex to update `AGENTS.md` from `CLAUDE.md`, preserving the Personal Preferences section verbatim and keeping the workspace context concise.

## Sync

1. `cd ~/Projects`
2. `./pull-configs.sh` — pull `ai-configs` and cursor rules, verify symlink
3. If `CLAUDE.md` changed: `./refresh-agents.sh` → paste into Codex → review diff → commit
4. If personal preferences changed: manually update `AGENTS.md` and `personal-preferences.mdc` to match
