#!/bin/bash
# PostCompact Hook — runs AFTER context compaction
# Injects recovery instructions into Claude's context

VAULT="__VAULT_BASE__/__VAULT_NAME__"
STATE="$VAULT/4. Активная работа/SESSION_STATE.md"

CONTEXT="КОНТЕКСТ СЖАТ. ОБЯЗАТЕЛЬНО: 1) Прочитать SESSION_STATE.md: $STATE 2) Прочитать CLAUDE.md 3) Найти строку с → в плане 4) Инкрементировать compression_count 5) Продолжить этот шаг. ЗАПРЕЩЕНО: спрашивать на чём остановились, пересказывать, менять план. ПЕРВОЕ СООБЩЕНИЕ = Далее — [действие]."

if [ -f "$STATE" ]; then
  TASK_ID=$(grep "^task_id:" "$STATE" 2>/dev/null | head -1 | sed 's/^task_id: *//' | tr -d '"')
  CURRENT_STEP=$(grep "^→" "$STATE" 2>/dev/null | head -1)
  NEXT_ACTION=$(sed -n '/^## Следующее действие/,/^##/p' "$STATE" 2>/dev/null | grep -v "^##" | head -1 | sed 's/^ *//')

  [ -n "$TASK_ID" ] && CONTEXT="$CONTEXT ЗАДАЧА: $TASK_ID."
  [ -n "$CURRENT_STEP" ] && CONTEXT="$CONTEXT ТЕКУЩИЙ ШАГ: $CURRENT_STEP"
  [ -n "$NEXT_ACTION" ] && CONTEXT="$CONTEXT СЛЕДУЮЩЕЕ: $NEXT_ACTION"
else
  CONTEXT="$CONTEXT WARNING: SESSION_STATE.md не найден. Создать немедленно."
fi

CONTEXT_ESCAPED=$(echo "$CONTEXT" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g' | tr '\n' ' ')

echo "{\"continue\": true, \"additionalContext\": \"$CONTEXT_ESCAPED\"}"
exit 0
