---
name: brain-protocol
description: >
  Full vault-based memory and session continuity protocol. Use at EVERY session start,
  when the user says "продолжай", "дальше", "continue", after context compaction,
  before any multi-step task, when context feels incomplete, or when working with
  SESSION_STATE.md, vault structure, or change logs.
metadata:
  version: "2.0.0"
  author: "Bogdan Yadykin"
---

# Brain Protocol — Full Methodology

## Configuration

Read `.claude/brain.conf` in the project root to get vault parameters:
```
vault_name=ProjectName
```

Derive paths:
```
VAULT = ~/Documents/Obsidian Vault/$vault_name
STATE = $VAULT/4. Активная работа/SESSION_STATE.md
```

## Vault Map (6-folder structure)

| Folder | Contents | When to read |
|--------|----------|-------------|
| `1. Проект/` | Project overview, tech stack, architecture | New context start, architecture tasks |
| `2. Модули/` | Module documentation (one file per module, with YAML properties) | **MANDATORY** before changing a module |
| `3. Журнал/YYYY-MM/` | History of ALL changes | **MANDATORY** before changing a module |
| `4. Активная работа/` | **SESSION_STATE.md**, _state_backups/ | **FIRST THING** every session |
| `5. Планы/` | Roadmap, bugs & tech debt, ideas, feature requests | Planning, refactoring, large tasks |
| `6. Справочник/` | Design system, core functions, code patterns, **TEMPLATES.md** | Writing new code, PR, vault entries |

### YAML Properties (every file must have)
```yaml
---
title: Module Name
type: module | changelog | audit | reference | roadmap | project
status: active | done | draft | archived
created: YYYY-MM-DD
updated: YYYY-MM-DD
related:
  - "[[Related Module 1]]"
  - "[[Related Module 2]]"
owner: Author
---
```

## SESSION_STATE.md Format

```markdown
---
last_updated: YYYY-MM-DD HH:MM
task_id: "short-id-001"
compression_count: 0
---
# ACTIVE TASK
## Задача
[EXACT wording]
## План
- [x] Step 1: [action] — DONE [result]
→ [ ] Step 2: [action] ← CURRENT
- [ ] Step 3: [action]
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
[Verbatim]
## Следующее действие
[File + specific action. "Continue work" = INVALID]
---
# ОЧЕРЕДЬ (one-liners, no details)
| # | Task | Priority | Status |
|---|------|----------|--------|
```

## Work Protocol

```
STEP 0 → Read STATE. Unfinished task? Ask user.
STEP 1 → Identify modules. Read 3. Журнал/ + 2. Модули/ for them. Large tasks: + 6. Справочник/ + 1. Проект/.
STEP 1.5 → grep codebase for existing implementations before writing new code.
STEP 2 → Create plan in STATE (steps = specific actions with file names).
          Batch: first → ACTIVE, rest → queue.
STEP 3 → Execute. BEFORE step → move →. AFTER → mark [x].
STEP 4 → Done → entry in 3. Журнал/. Update 2. Модули/, 5. Планы/, 6. Справочник/ as needed.
STEP 5 → Rotate STATE: clear, next from queue → ACTIVE → STEP 1.
```

## STATE Read/Write Rules

**WRITE to STATE** — BEFORE and AFTER each step, on file change, on decision, on user clarification, every 5 messages forced.

**READ STATE** — at first message in dialog, on "continue/дальше", when context details feel missing, before continuing multi-step task.

## Recovery After Compaction

```
A: Read STATE
B: Read latest file from 3. Журнал/[current month]/
C: Read WIP from 4. Активная работа/
D: compression_count += 1
E: Find → in plan → execute THAT step
```

**FORBIDDEN** after recovery: asking "where were we", summarizing done work, changing plan, skipping steps.

**MANDATORY:** continue from → step, first message = "Далее — [action]".

## STATE Rotation

- ACTIVE TASK — always 1 task with details
- Queue — one-liners, no limit
- Completed task → entry in 3. Журнал/, delete from STATE
- Next from queue → expand into ACTIVE TASK
- Goal: STATE < 80 lines

## STATE Validation

Before saving, check: "Следующее действие" contains filename + action, exactly one line with →, `last_updated` is current. Invalid STATE — rewrite.

## Token Economy

### grep-before-implement (saves 70K tokens per incident)

**BEFORE writing new code or feature:**
```
grep -r "keyword" src/        # 100 tokens
read found files               # 2K tokens
ask user if unclear            # 500 tokens
# TOTAL: ~2.6K vs 70K if building what already exists
```

**RULE:** Never implement functionality without searching codebase first.

### Minimize CLI output waste

- Use `--quiet`, `--no-verbose`, `| tail -n 20` for build/test commands
- Don't output entire files when specific lines are needed
- `grep -n` for line numbers, then read only needed range

### Post-compaction safety

After compaction, behavior may shift from careful (Read→Read→Read→Edit) to risky (Edit→Edit). Before any Edit after compaction:
1. Read STATE — what was already investigated?
2. Read "Проверено/Найдено" section — which files/code were already found?
3. Only then proceed with changes

## Additional Resources

- **`references/project-rules.md`** — project-specific critical rules template
- **`references/templates.md`** — entry templates for vault folders (3. Журнал/, 5. Планы/, 2. Модули/)
