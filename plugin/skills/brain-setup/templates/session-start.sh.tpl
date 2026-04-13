#!/bin/bash
# SessionStart Hook — runs at EVERY Claude session start
# Reminds Claude to read SESSION_STATE.md first

VAULT="__VAULT_BASE__/__VAULT_NAME__"
STATE="$VAULT/03 — Активная Разработка и Детали Текущих Задач/SESSION_STATE.md"

CONTEXT="СТАРТ СЕССИИ. ПЕРВЫМ ДЕЛОМ прочитай: 1) SESSION_STATE.md: $STATE 2) Секцию 4 CLAUDE.md (протокол непрерывности)."

if [ -f "$STATE" ]; then
  TASK_ID=$(grep "^task_id:" "$STATE" 2>/dev/null | head -1 | sed 's/^task_id: *//' | tr -d '"')
  CURRENT_STEP=$(grep "^→" "$STATE" 2>/dev/null | head -1)
  LAST_UPDATED=$(grep "^last_updated:" "$STATE" 2>/dev/null | head -1 | sed 's/^last_updated: *//')

  [ -n "$TASK_ID" ] && CONTEXT="$CONTEXT ЗАДАЧА: $TASK_ID."
  [ -n "$LAST_UPDATED" ] && CONTEXT="$CONTEXT ОБНОВЛЕНО: $LAST_UPDATED."
  [ -n "$CURRENT_STEP" ] && CONTEXT="$CONTEXT ТЕКУЩИЙ ШАГ: $CURRENT_STEP"
else
  CONTEXT="$CONTEXT WARNING: SESSION_STATE.md не найден. Создай по шаблону из brain-protocol skill."
fi

CONTEXT_ESCAPED=$(echo "$CONTEXT" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g' | tr '\n' ' ')

echo "{\"continue\": true, \"additionalContext\": \"$CONTEXT_ESCAPED\"}"
exit 0
