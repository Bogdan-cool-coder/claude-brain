---
name: brain-setup
description: >
  Set up brain hooks and vault structure for a new project. Use when the user says
  "настрой brain", "setup brain", "подключи brain к проекту", "initialize brain",
  or when brain.conf is missing and the project needs session continuity configured.
metadata:
  version: "3.0.0"
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
├── 1. Проект/              # Overview, tech stack, architecture
├── 2. Модули/              # One file per module (with YAML properties)
├── 3. Журнал/              # Change log entries
│   └── YYYY-MM/
├── 4. Активная работа/     # SESSION_STATE.md + WIP
│   └── _state_backups/
├── 5. Планы/               # Roadmap, bugs, tech debt, ideas
├── 6. Справочник/          # Design system, core functions, patterns, TEMPLATES.md
└── 7. Вики/                # Product knowledge base (human-facing) — see references/wiki-guide.md
    └── 00 — Индекс.md      # Wiki master index (seed it)
```

`7. Вики/` is optional but recommended for products with non-technical audiences (marketing/managers/users). Seed `00 — Индекс.md` from the structure in `references/wiki-guide.md` (sections A. Для сайта / B. User Guide / C. Сценарии / D. Тех / E. Связи / F. Бренд). Articles are filled later.

## Step 4: Create SESSION_STATE.md

Write initial STATE at `$VAULT/4. Активная работа/SESSION_STATE.md`:

```markdown
---
last_updated: <current datetime>
task_id: "setup-001"
compression_count: 0
session_label: ""
---
# SESSION_STATE — <ProjectName>
## Сейчас
Initial brain setup.
→ Следующий шаг: project CLAUDE.md — добавить Continuity-блок + критичные правила проекта
## Очередь
- [ ] заполнить критичные правила проекта
## Решения (свежие)
## Заметки / контекст
[начальная настройка]
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
  "compactPrompt": "При сжатии контекста ОБЯЗАТЕЛЬНО сохрани в summary:\n1. Путь к SESSION_STATE.md\n2. Текущий шаг — строка '→ Следующий шаг:' из SESSION_STATE\n3. Все имена изменённых файлов этой сессии\n4. Все принятые решения с обоснованием\n5. Дословные требования пользователя по текущей задаче\n6. task_id текущей задачи\n7. Инструкция: ПОСЛЕ СЖАТИЯ сначала прочитать SESSION_STATE.md и Continuity-блок в CLAUDE.md, затем продолжить со строки '→ Следующий шаг:'",
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

## Step 7: Inject Continuity block into project CLAUDE.md (idempotent)

The session-start / post-compact hooks reference a «🧠 Continuity» block in the project CLAUDE.md. Add it **idempotently** — insert only if missing, NEVER overwrite an existing one:

1. Read the project `CLAUDE.md` (create if absent).
2. If it already contains a heading «🧠 Continuity» — leave it untouched.
3. Otherwise append the block (adapt from `templates/CLAUDE.cli.md.template` in shared templates — sections «🧭 Матрица-роутер» + «🧠 Continuity»), with `{{VAULT}}` / `{{PROJECT_NAME}}` substituted.

Rule: insert-if-missing, never overwrite. Same principle as «один SESSION_STATE — mv, не copy».

## Step 8: Verify

1. Check all files exist.
2. Run each hook script manually and verify JSON output (task_id / `→ Следующий шаг:` extracted).
3. Confirm `compression_count` bumps after a pre-compact run.
4. Report setup status to user.

## Step 9: Guide Next Steps

Tell the user:
- brain.conf created — vault linked to project
- Hooks installed — session-start, pre-compact, post-compact (v3.0)
- SESSION_STATE.md initialized (v3 format with `→ Следующий шаг:` anchor)
- Continuity block added to CLAUDE.md
- Next: fill project-specific critical rules in CLAUDE.md (see `references/project-rules.md` in brain-protocol skill)
