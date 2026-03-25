# ai-configs

Personal AI assistant configs: `CLAUDE.md` for Claude Code and a `.cursor` symlink for conversion-bot.

## Setup

### CLAUDE.md

Clone this repo into a shared parent directory alongside your other Adobe dev repos. For example, if your parent directory is `~/Projects/`, the structure would look like:

```
~/Projects/
├── ai-configs/                       # this repo
├── adp-devsite/
├── devsite-runtime-connector/
├── adp-devsite-github-actions-test/
└── dev-docs-template/
```

`CLAUDE.md` is scoped to that parent directory so Claude Code picks it up across all of them.

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
