#!/bin/bash
# PostCompact Hook (Brain Protocol v3.0) — runs AFTER context compaction.
# Injects recovery instructions. compression_count already bumped by pre-compact.

VAULT="__VAULT_BASE__/__VAULT_NAME__"
STATE="$VAULT/4. Активная работа/SESSION_STATE.md"

CONTEXT="КОНТЕКСТ СЖАТ. ОБЯЗАТЕЛЬНО: 1) Прочитать SESSION_STATE.md: $STATE 2) Прочитать Continuity-блок в CLAUDE.md 3) Найти строку '→ Следующий шаг:' 4) Продолжить С ЭТОГО шага. ЗАПРЕЩЕНО: спрашивать на чём остановились, пересказывать, менять план. ПЕРВОЕ СООБЩЕНИЕ = 'Далее — [действие из STATE]'."

if [ -f "$STATE" ]; then
  TASK_ID=$(grep "^task_id:" "$STATE" 2>/dev/null | head -1 | sed 's/^task_id: *//' | tr -d '"')

  NEXT_STEP=$(grep "^→ Следующий шаг:" "$STATE" 2>/dev/null | head -1)
  [ -z "$NEXT_STEP" ] && NEXT_STEP=$(grep "^→" "$STATE" 2>/dev/null | head -1)
  if [ -z "$NEXT_STEP" ]; then
    NEXT_STEP=$(sed -n '/^## Следующее действие/,/^##/p' "$STATE" 2>/dev/null | grep -v "^##" | head -1 | sed 's/^ *//')
  fi

  [ -n "$TASK_ID" ] && CONTEXT="$CONTEXT ЗАДАЧА: $TASK_ID."
  [ -n "$NEXT_STEP" ] && CONTEXT="$CONTEXT СЛЕДУЮЩЕЕ: $NEXT_STEP"
else
  CONTEXT="$CONTEXT WARNING: SESSION_STATE.md не найден. Создать немедленно."
fi

CONTEXT_ESCAPED=$(echo "$CONTEXT" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g' | tr '\n' ' ')
echo "{\"continue\": true, \"additionalContext\": \"$CONTEXT_ESCAPED\"}"
exit 0
