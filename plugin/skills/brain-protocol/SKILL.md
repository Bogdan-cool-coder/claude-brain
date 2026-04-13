---
name: brain-protocol
description: >
  Full vault-based memory and session continuity protocol. Use at EVERY session start,
  when the user says "продолжай", "дальше", "continue", after context compaction,
  before any multi-step task, when context feels incomplete, or when working with
  SESSION_STATE.md, vault structure, or change logs.
metadata:
  version: "0.1.0"
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
STATE = $VAULT/03 — Активная Разработка и Детали Текущих Задач/SESSION_STATE.md
```

## Vault Map

| Folder | Contents | When to read |
|--------|----------|-------------|
| `00` | README, stack, versions | New context start |
| `01` | Architecture, API, DB | Tasks affecting architecture |
| `02/YYYY-MM/` | History of ALL changes | **MANDATORY** before changing a module |
| `03` | **SESSION_STATE.md**, WIP | **FIRST THING** every session |
| `04` | Bug analyses | Working on a module with past bugs |
| `05` | Tech debt, risks | Refactoring, large tasks |
| `06` | Ideas, feature requests | Planning features |
| `07` | Module documentation | **MANDATORY** before changing a module |
| `08` | Snippets, patterns | Writing new code |
| `09` | Servers, CI/CD, deploy | Infrastructure tasks |
| `10` | Git-flow, standards, **TEMPLATES.md** | PR, commits, vault entries |

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
STEP 1 → Identify modules. Read 02/ + 07/ for them. Large tasks: + 08/ + 01/.
STEP 1.5 → grep codebase for existing implementations before writing new code.
STEP 2 → Create plan in STATE (steps = specific actions with file names).
          Batch: first → ACTIVE, rest → queue.
STEP 3 → Execute. BEFORE step → move →. AFTER → mark [x].
STEP 4 → Done → entry in 02/. Update 07/ 04/ 05/ 08/ as needed.
STEP 5 → Rotate STATE: clear, next from queue → ACTIVE → STEP 1.
```

## STATE Read/Write Rules

**WRITE to STATE** — BEFORE and AFTER each step, on file change, on decision, on user clarification, every 5 messages forced.

**READ STATE** — at first message in dialog, on "continue/дальше", when context details feel missing, before continuing multi-step task.

## Recovery After Compaction

```
A: Read STATE
B: Read latest file from 02/[current month]/
C: Read WIP from 03/
D: compression_count += 1
E: Find → in plan → execute THAT step
```

**FORBIDDEN** after recovery: asking "where were we", summarizing done work, changing plan, skipping steps.

**MANDATORY:** continue from → step, first message = "Далее — [action]".

## STATE Rotation

- ACTIVE TASK — always 1 task with details
- Queue — one-liners, no limit
- Completed task → entry in 02/, delete from STATE
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
- **`references/templates.md`** — entry templates for vault folders 02/, 04/, 05/
