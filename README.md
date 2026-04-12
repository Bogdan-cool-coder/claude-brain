# Claude Brain

**Persistent memory system for Claude Code that survives 200K token context compaction.**

[Русская версия](README.ru.md)

## The Problem

Claude Code loses all context when conversation hits 200K tokens. After compaction, Claude forgets the current task, plan, and decisions — often asking "where did we stop?" or starting over.

## The Solution

Claude Brain uses Obsidian Vault (or any folder) as external memory with automatic state management.

### Two versions available:

| | CLI Version | Desktop Version |
|--|------------|----------------|
| **Protection** | 5/5 levels (full) | 3/5 levels (partial) |
| **How it works** | Hooks auto-save/restore context | Enhanced CLAUDE.md + launchd backups |
| **Platform** | Claude Code CLI in Terminal | Claude Desktop app (Code tab) |
| **After compaction** | Claude continues instantly from exact step | Claude reads STATE from CLAUDE.md instructions |
| **Backups** | Hook-triggered + every 5 min | Every 5 min (launchd) |

### CLI: 5 levels of protection

| Level | Mechanism | What it does |
|-------|-----------|-------------|
| 1 | CLAUDE.md | Auto-loaded rules and continuity protocol |
| 2 | compactPrompt | Guides what Claude preserves during compaction |
| 3 | PreCompact hook | Backs up SESSION_STATE.md before compaction |
| 4 | PostCompact hook | Injects task context after compaction |
| 5 | SessionStart hook | Reminds Claude to read state on every launch |

### Desktop: 3 levels of protection

| Level | Mechanism | What it does |
|-------|-----------|-------------|
| 1 | Enhanced CLAUDE.md | Aggressive self-preservation instructions |
| 2 | compactPrompt | Guides what Claude preserves during compaction |
| 3 | launchd backup | Auto-backup SESSION_STATE every 5 minutes |

> **Note:** Desktop hooks don't work due to a [known bug](https://github.com/anthropics/claude-code/issues/42336). Desktop version compensates with stronger CLAUDE.md instructions and automatic backups.

## Quick Start

### Prerequisites

- **macOS** or **Linux**
- **Claude Code CLI** (`npm install -g @anthropic-ai/claude-code`) — for CLI version
- **Claude Desktop app** — for Desktop version
- A folder for project vaults (Obsidian recommended but not required)

### Install

```bash
git clone https://github.com/bogdan-cool-coder/claude-brain.git
cd claude-brain
bash install.sh
```

The installer shows a menu:

```
Choose what to install:

  1) CLI version        — Full protection (5/5 levels)
  2) Desktop version    — Partial protection (3/5 levels)
  3) Both               — CLI + Desktop (recommended)
```

Then optionally make `claude-brain` available as a command:

```bash
sudo ln -sf ~/.claude/hooks/claude-brain /usr/local/bin/claude-brain
```

### Initialize a Project

```bash
cd ~/your/project
claude-brain init MyProject
```

This creates: vault folder with structured directories (00-10), `CLAUDE.md` in your project root, `SESSION_STATE.md`, and `.claude/brain.conf`.

### Start Working

```bash
cd ~/your/project
claude              # CLI version
```

For Desktop: open the project in Claude Desktop's Code tab. CLAUDE.md will be loaded automatically.

## How It Works

### Vault Structure

Each project gets a vault folder with 11 directories:

```
Obsidian Vault/MyProject/
├── 00 — General Info/
├── 01 — Architecture/
├── 02 — Change History/        (by month)
├── 03 — Active Development/    (SESSION_STATE.md lives here)
├── 04 — Bug Reports/
├── 05 — Tech Debt/
├── 06 — Ideas/
├── 07 — Module Docs/
├── 08 — Snippets/
├── 09 — Infrastructure/
└── 10 — Process/
```

### SESSION_STATE.md

The heart of the system — tracks current task, plan (with → marking active step), changed files, **verified/found code** (prevents duplicate searches after compaction), decisions, and next action.

### Token Economy Rules (NEW in v1.1)

Based on [community research](https://github.com/anthropics/claude-code/issues/13579) documenting 700K+ tokens wasted across common patterns:

- **grep-before-implement** — always search codebase before writing new code. `grep` costs 100 tokens vs 70K for reimplementing existing functionality
- **Verified/Found section** in STATE — tracks what was already searched and found, preventing duplicate investigation after compaction
- **Post-compaction drift protection** — explicit rule to read STATE and Verified/Found before any Edit after compaction, countering the behavioral shift from careful (Read→Read→Edit) to reckless (Edit→Edit)

### Hook Flow (CLI)

```
SessionStart → Remind Claude to read STATE
     ↓
[Claude works, context grows to 200K]
     ↓
PreCompact  → Backup STATE
     ↓
[Context compacted]
     ↓
PostCompact → Inject: task ID, current step, next action
     ↓
Claude reads STATE → Continues from → step
```

### Desktop Flow

```
CLAUDE.md loaded → Claude reads STATE on start
     ↓
[Claude works, saves STATE every 5 messages]
     ↓
[Context compacted — compactPrompt preserves key info]
     ↓
Claude reads CLAUDE.md → Reads STATE → Continues from → step
     ↓
launchd → Backups every 5 min (safety net)
```

## Commands

```bash
claude-brain init [name]   # Initialize project vault
claude-brain status        # Show current project state
claude-brain list          # List all brain-enabled projects
```

## Repository Structure

```
claude-brain/
├── install.sh              # Main installer (choose CLI/Desktop/Both)
├── cli/
│   ├── install.sh          # CLI-specific installer
│   ├── hooks/              # Hook scripts (SessionStart, PreCompact, PostCompact)
│   └── settings.json       # Settings with hooks + compactPrompt
├── desktop/
│   ├── install.sh          # Desktop-specific installer
│   ├── backup-state.sh     # launchd backup script
│   └── settings.desktop.json  # Settings with compactPrompt only
└── shared/
    ├── claude-brain         # CLI management tool
    └── templates/
        ├── CLAUDE.cli.md.template
        ├── CLAUDE.desktop.md.template
        └── SESSION_STATE.md.template
```

## Important Notes

- **CLI version** requires Claude Code CLI v2.0+. Hooks don't work in Desktop app ([bug #42336](https://github.com/anthropics/claude-code/issues/42336)).
- **Desktop version** works in Claude Desktop's Code tab with partial protection.
- **Both versions** can be installed together — they don't conflict.
- **Obsidian is optional.** Any folder works as a vault.
- **Per-project override.** Add `.claude/brain.conf` with `vault_name=CustomName` if vault name differs from directory name.

## License

MIT
