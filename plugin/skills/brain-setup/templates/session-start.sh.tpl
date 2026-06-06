#!/bin/bash
# SessionStart Hook (Brain Protocol v3.0) — runs at EVERY Claude session start.
# Reminds Claude to read SESSION_STATE.md first + parallel-session guard.

VAULT="__VAULT_BASE__/__VAULT_NAME__"
STATE="$VAULT/4. Активная работа/SESSION_STATE.md"

CONTEXT="СТАРТ СЕССИИ. ПЕРВЫМ ДЕЛОМ прочитай: 1) SESSION_STATE.md: $STATE 2) Continuity-блок в CLAUDE.md (раздел 🧠)."

if [ -f "$STATE" ]; then
  TASK_ID=$(grep "^task_id:" "$STATE" 2>/dev/null | head -1 | sed 's/^task_id: *//' | tr -d '"')
  LAST_UPDATED=$(grep "^last_updated:" "$STATE" 2>/dev/null | head -1 | sed 's/^last_updated: *//')
  SESSION_LABEL=$(grep "^session_label:" "$STATE" 2>/dev/null | head -1 | sed 's/^session_label: *//' | tr -d '"')

  CURRENT_STEP=$(grep "^→ Следующий шаг:" "$STATE" 2>/dev/null | head -1)
  [ -z "$CURRENT_STEP" ] && CURRENT_STEP=$(grep "^→" "$STATE" 2>/dev/null | head -1)

  [ -n "$TASK_ID" ] && CONTEXT="$CONTEXT ЗАДАЧА: $TASK_ID."
  [ -n "$LAST_UPDATED" ] && CONTEXT="$CONTEXT ОБНОВЛЕНО: $LAST_UPDATED."
  [ -n "$CURRENT_STEP" ] && CONTEXT="$CONTEXT ТЕКУЩИЙ ШАГ: $CURRENT_STEP"

  # Parallel-session guard (time-based)
  if [ -n "$LAST_UPDATED" ]; then
    LU_CLEAN=$(echo "$LAST_UPDATED" | sed 's/ (.*)//' | sed 's/[[:space:]]*$//')
    NOW_EPOCH=$(date +%s)
    if [[ "$OSTYPE" == "darwin"* ]]; then
      LU_EPOCH=$(date -j -f "%Y-%m-%d %H:%M" "$LU_CLEAN" +%s 2>/dev/null)
    else
      LU_EPOCH=$(date -d "$LU_CLEAN" +%s 2>/dev/null)
    fi
    if [ -n "$LU_EPOCH" ]; then
      DIFF=$(( (NOW_EPOCH - LU_EPOCH) / 60 ))
      if [ "$DIFF" -ge 0 ] && [ "$DIFF" -le 10 ]; then
        CONTEXT="$CONTEXT ⚠ PARALLEL-GUARD: STATE обновлён ${DIFF} мин назад (session_label: ${SESSION_LABEL:-?}). Возможна параллельная сессия — не затирай STATE вслепую. SESSION_STATE один, дубль не создавать."
      fi
    fi
  fi
else
  CONTEXT="$CONTEXT WARNING: SESSION_STATE.md не найден. Создай по шаблону из brain-protocol skill."
fi

CONTEXT_ESCAPED=$(echo "$CONTEXT" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g' | tr '\n' ' ')
echo "{\"continue\": true, \"additionalContext\": \"$CONTEXT_ESCAPED\"}"
exit 0
