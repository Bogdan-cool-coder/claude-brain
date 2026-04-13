# Claude Brain — Cowork Plugin

Persistent memory system for Claude. Session continuity, vault-based memory, token economy, and auto-recovery after context compaction.

## What it does

This plugin gives Claude persistent memory across sessions and automatic recovery after context compaction. It uses an Obsidian vault as external storage for session state, change logs, module docs, and task queues.

## Components

| Component | Name | Purpose |
|-----------|------|---------|
| CLAUDE.md | Always-on rules | Core continuity protocol, absolute rules, token economy — loaded automatically |
| Skill | `brain-protocol` | Full vault methodology: vault map, STATE format, work protocol, templates |
| Skill | `brain-setup` | One-command setup of hooks and vault structure for any new project |

## Setup

### For a new project

1. Install the plugin
2. In any session, say: **"настрой brain"** or **"setup brain"**
3. Provide your vault name and path when asked
4. Done — hooks, STATE, and vault folders are created automatically

### What gets created

- `.claude/brain.conf` — vault link config
- `.claude/hooks/` — three bash scripts for session lifecycle
- `.claude/settings.json` — hook registrations + compact prompt
- Obsidian vault folders (00-10) with SESSION_STATE.md

## Usage

### Automatic (via CLAUDE.md + hooks)

- **Session start**: Claude reads SESSION_STATE.md and picks up where it left off
- **Pre-compact**: STATE is backed up before context compaction
- **Post-compact**: Claude receives recovery instructions and continues without asking

### Manual triggers

- **"продолжай" / "дальше" / "continue"** — triggers brain-protocol skill, reads STATE
- **"настрой brain" / "setup brain"** — triggers brain-setup for new project initialization

## How it works

1. **CLAUDE.md** (always loaded) contains the core rules: read STATE first, recover after compaction, update STATE every 5 messages
2. **brain-protocol** skill has the full methodology: vault structure, STATE format, work protocol, templates for change logs and bug analyses
3. **brain-setup** skill automates hook installation — generates bash scripts from templates with correct vault paths
4. **Hooks** (installed per-project) handle the lifecycle: inject context at start, backup before compaction, inject recovery instructions after

## Author

Bogdan Yadykin
