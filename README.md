# Claude Brain

**Persistent memory system for Claude Code CLI that survives 200K token context compaction.**

Claude Code loses all context when the conversation hits 200K tokens and gets compacted. Claude Brain solves this by using Obsidian Vault (or any folder) as external memory, with hooks that automatically save state before compaction and restore it after.

## The Problem

When working on complex projects, Claude Code regularly hits the 200K token context limit. After compaction, Claude forgets the current task, plan, decisions, and progress — often asking "where did we stop?" or starting over.

## The Solution

Claude Brain implements 5 levels of protection:

| Level | Mechanism | What it does |
|-------|-----------|-------------|
| 1 | **CLAUDE.md** | Auto-loaded rules and continuity protocol |
| 2 | **compactPrompt** | Guides what Claude preserves during compaction |
| 3 | **PreCompact hook** | Backs up SESSION_STATE.md before compaction |
| 4 | **PostCompact hook** | Injects task context after compaction |
| 5 | **SessionStart hook** | Reminds Claude to read state on every launch |

After compaction, Claude immediately reads SESSION_STATE.md, finds the current step (marked with →), and continues with "Next — [action]" without asking any questions.

## Quick Start

### Prerequisites

- **Claude Code CLI** v2.0+ (`npm install -g @anthropic-ai/claude-code`)
- **macOS** or **Linux**
- A folder for project vaults (Obsidian Vault recommended but not required)

### Install (one time)

```bash
git clone https://github.com/bogdan-cool-coder/claude-brain.git
cd claude-brain
bash install.sh
```

The installer will ask for your vault folder path and set up everything globally.

Then optionally make `claude-brain` available as a command:

```bash
sudo ln -sf ~/.claude/hooks/claude-brain /usr/local/bin/claude-brain
```

### Initialize a Project

```bash
cd ~/your/project
claude-brain init MyProject
```

This creates:
- Vault folder with structured directories (00-10)
- `CLAUDE.md` in your project root with the continuity protocol
- `SESSION_STATE.md` for tracking active tasks
- `.claude/brain.conf` mapping your project to its vault

### Start Working

```bash
cd ~/your/project
claude
```

That's it. The hooks will automatically activate when Claude Code starts in a brain-enabled project.

## How It Works

### Vault Structure

Each project gets a vault folder with 11 directories:

```
Obsidian Vault/MyProject/
├── 00 — General Info/          # README, stack, versions
├── 01 — Architecture/          # Architecture, API, DB
├── 02 — Change History/        # History of ALL changes (by month)
├── 03 — Active Development/    # SESSION_STATE.md, WIP
├── 04 — Bug Reports/           # Bug postmortems
├── 05 — Tech Debt/             # Tech debt, risks
├── 06 — Ideas/                 # Feature requests
├── 07 — Module Docs/           # Module documentation
├── 08 — Snippets/              # Code snippets, patterns
├── 09 — Infrastructure/        # Servers, CI/CD
└── 10 — Process/               # Git-flow, standards
```

### SESSION_STATE.md

The heart of the system — a structured file that tracks:
- Current task and plan (with → marking the active step)
- Changed files and decisions
- Compression count
- Next action (must include a specific filename)

### Hook Flow

```
SessionStart → Remind Claude to read STATE
     ↓
[Claude works, context grows to 200K]
     ↓
PreCompact  → Backup STATE, timestamp
     ↓
[Context compacted]
     ↓
PostCompact → Inject: task ID, current step, next action
     ↓
Claude reads STATE → Continues from → step
```

## Commands

```bash
claude-brain init [name]   # Initialize project vault
claude-brain status        # Show current project state
claude-brain list          # List all brain-enabled projects
```

## File Structure

```
~/.claude/
├── settings.json          # Global hooks config
├── brain-config           # Vault root path
├── hooks/
│   ├── _detect-project.sh # Auto-detects project and vault
│   ├── session-start.sh   # SessionStart hook
│   ├── pre-compact.sh     # PreCompact hook
│   ├── post-compact.sh    # PostCompact hook
│   └── claude-brain       # CLI management tool
└── templates/
    ├── CLAUDE.md.template
    └── SESSION_STATE.md.template
```

## Important Notes

- **Claude Code CLI only.** Hooks don't work in the desktop app's Code tab (known bug: [#42336](https://github.com/anthropics/claude-code/issues/42336)).
- **Obsidian is optional.** Any folder works as a vault. Obsidian just makes it easy to browse and edit vault files.
- **Per-project override.** Add `.claude/brain.conf` with `vault_name=CustomName` if your vault name differs from the directory name.
- **Backups.** PreCompact keeps the last 20 SESSION_STATE backups automatically.

## License

MIT
