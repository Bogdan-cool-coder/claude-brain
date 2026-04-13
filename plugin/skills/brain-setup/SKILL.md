---
name: brain-setup
description: >
  Set up brain hooks and vault structure for a new project. Use when the user says
  "настрой brain", "setup brain", "подключи brain к проекту", "initialize brain",
  or when brain.conf is missing and the project needs session continuity configured.
metadata:
  version: "0.1.0"
  author: "Bogdan Yadykin"
---

# Brain Setup — Auto-Install Hooks for New Project

Set up the full brain infrastructure in the current project. This creates hooks, config, vault folders, and SESSION_STATE.md.

## Step 1: Gather Parameters

Ask the user for:
1. **Vault name** — name of the Obsidian vault folder (e.g., "FinFamily", "MyProject")
2. **Vault base path** — path to Obsidian vaults (default: `~/Documents/Obsidian Vault`)
3. **Project root** — path to the project repo (detect from current working directory)

## Step 2: Create brain.conf

Write `.claude/brain.conf` in the project root:
```
vault_name=<VaultName>
vault_base=<VaultBasePath>
```

## Step 3: Create Vault Structure

Create these folders in the vault if they don't exist:
```
$VAULT_BASE/$VAULT_NAME/
├── 00 — Обзор Проекта/
├── 01 — Архитектура/
├── 02 — Журнал Изменений/
│   └── YYYY-MM/
├── 03 — Активная Разработка и Детали Текущих Задач/
│   └── _state_backups/
├── 04 — Разборы Багов/
├── 05 — Техдолг и Риски/
├── 06 — Идеи/
├── 07 — Документация Модулей/
├── 08 — Сниппеты и Паттерны/
├── 09 — Инфраструктура/
└── 10 — Процесс Разработки/
```

## Step 4: Create SESSION_STATE.md

Write initial STATE at `$VAULT/03 — Активная Разработка и Детали Текущих Задач/SESSION_STATE.md`:

```markdown
---
last_updated: <current datetime>
task_id: "setup-001"
compression_count: 0
---
# ACTIVE TASK
## Задача
Initial brain setup
## План
- [x] Step 1: brain.conf created
→ [ ] Step 2: Configure project-specific rules
## Изменённые файлы
| File | Change | Status |
|------|--------|--------|
## Проверено/Найдено
| What searched | Where found | Key detail |
|--------------|------------|------------|
## Решения
| Decision | Why | Rejected |
|----------|-----|----------|
## Контекст от пользователя
[Initial setup]
## Следующее действие
Project CLAUDE.md — add project-specific critical rules
---
# ОЧЕРЕДЬ
| # | Task | Priority | Status |
|---|------|----------|--------|
```

## Step 5: Create Hook Scripts

Create `.claude/hooks/` directory with three scripts. Use templates from `templates/` in this skill directory.

Read each template, replace `__VAULT_BASE__` and `__VAULT_NAME__` with actual values, and write to:
- `.claude/hooks/session-start.sh`
- `.claude/hooks/pre-compact.sh`
- `.claude/hooks/post-compact.sh`

Make all scripts executable: `chmod +x .claude/hooks/*.sh`

## Step 6: Configure settings.json

Read existing `.claude/settings.json` (or create if missing). Merge hook configuration:

```json
{
  "compactPrompt": "При сжатии контекста ОБЯЗАТЕЛЬНО сохрани в summary:\n1. Путь к SESSION_STATE.md\n2. Текущий шаг плана (строка с →)\n3. Все имена изменённых файлов\n4. Все принятые решения\n5. task_id текущей задачи\n6. Инструкция: ПОСЛЕ СЖАТИЯ первым делом прочитать SESSION_STATE.md",
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash <PROJECT_ROOT>/.claude/hooks/session-start.sh"
          }
        ]
      }
    ],
    "PreCompact": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash <PROJECT_ROOT>/.claude/hooks/pre-compact.sh"
          }
        ]
      }
    ],
    "PostCompact": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash <PROJECT_ROOT>/.claude/hooks/post-compact.sh"
          }
        ]
      }
    ]
  }
}
```

Replace `<PROJECT_ROOT>` with the actual project path, escaping spaces with `\\ `.

Preserve any existing settings (permissions, other hooks) — merge, don't overwrite.

## Step 7: Verify

1. Check all files exist
2. Run each hook script manually and verify JSON output
3. Report setup status to user

## Step 8: Guide Next Steps

Tell the user:
- brain.conf created — vault linked to project
- Hooks installed — session-start, pre-compact, post-compact
- SESSION_STATE.md initialized
- Next: add project-specific critical rules to the project's CLAUDE.md (see `references/project-rules.md` in brain-protocol skill)
