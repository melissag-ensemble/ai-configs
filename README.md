# ai-configs

Personal AI assistant configs: `CLAUDE.md` for Claude Code, `AGENTS.md` for Codex, and a `.cursor` symlink for conversion-bot.

## Setup

### CLAUDE.md and AGENTS.md

Clone this repo into a shared parent directory alongside your other Adobe dev repos. For example, if your parent directory is `~/Projects/`, the structure would look like:

```
~/Projects/
├── ai-configs/                       # this repo
├── adp-devsite/
├── devsite-runtime-connector/
├── adp-devsite-github-actions-test/
└── dev-docs-template/
```

`CLAUDE.md` and `AGENTS.md` are scoped to that parent directory so Claude Code and Codex can pick them up across all child repos.
`CLAUDE.md` is the source of truth for shared institutional knowledge. `AGENTS.md` is the Codex-friendly version refreshed from `CLAUDE.md`.

### pull-configs.sh

Also clone the cursor rules repo into the same parent directory:

```bash
git clone https://github.com/AdobeDocs/adp-devsite-cursor-rules
```

## Usage

```bash
./pull-configs.sh
```

Pulls the latest `CLAUDE.md` and conversion-bot cursor rules, and ensures the `.cursor` symlink is set up.

If `CLAUDE.md` changed and you want to refresh the Codex version of the instructions:

```bash
./refresh-agents.sh
```

This prints a ready-to-paste Codex prompt and copies it to your clipboard on macOS. The prompt tells Codex to update `AGENTS.md` from `CLAUDE.md` while preserving the more concise, Codex-friendly structure.

## Sync

1. `cd ~/Projects`
2. `./pull-configs.sh` to pull `ai-configs` and cursor rules
3. `./refresh-agents.sh` to prepare the Codex prompt for `AGENTS.md`
4. Open Codex in a repo under `~/Projects`
5. Paste the copied prompt
6. Review the diff in `AGENTS.md`
7. Commit if the changes look right
