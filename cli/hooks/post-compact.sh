#!/bin/bash
# =============================================================
# PostCompact Hook (universal) — Brain Protocol v3.0
# Runs AFTER context compaction.
# Injects recovery context. compression_count already bumped by pre-compact.
# =============================================================

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$HOOK_DIR/_detect-project.sh"

# No vault — skip
if [ ! -d "$VAULT" ]; then
  echo '{"continue": true}'
  exit 0
fi

CONTEXT="CONTEXT COMPACTED [$VAULT_NAME]. ОБЯЗАТЕЛЬНО: 1) Прочитать SESSION_STATE.md: $STATE 2) Прочитать Continuity-блок в CLAUDE.md 3) Найти строку '→ Следующий шаг:' 4) Продолжить С ЭТОГО шага. ЗАПРЕЩЕНО: спрашивать на чём остановились, пересказывать сделанное, менять план. ПЕРВОЕ сообщение = 'Далее — [действие из STATE]'."

if [ -f "$STATE" ]; then
  TASK_ID=$(grep "^task_id:" "$STATE" 2>/dev/null | head -1 | sed 's/^task_id: *//' | tr -d '"')

  # Single canonical anchor (v3.0) with backward-compatible fallbacks (v2.0)
  NEXT_STEP=$(grep "^→ Следующий шаг:" "$STATE" 2>/dev/null | head -1)
  [ -z "$NEXT_STEP" ] && NEXT_STEP=$(grep "^→" "$STATE" 2>/dev/null | head -1)
  if [ -z "$NEXT_STEP" ]; then
    NEXT_STEP=$(sed -n '/^## Следующее действие/,/^##/p' "$STATE" 2>/dev/null | grep -v "^##" | head -1 | sed 's/^ *//')
  fi
  if [ -z "$NEXT_STEP" ]; then
    NEXT_STEP=$(sed -n '/^## Next Action/,/^##/p' "$STATE" 2>/dev/null | grep -v "^##" | head -1 | sed 's/^ *//')
  fi

  [ -n "$TASK_ID" ] && CONTEXT="$CONTEXT TASK: $TASK_ID."
  [ -n "$NEXT_STEP" ] && CONTEXT="$CONTEXT NEXT: $NEXT_STEP"
else
  CONTEXT="$CONTEXT WARNING: SESSION_STATE.md not found. Create immediately."
fi

CONTEXT_ESCAPED=$(json_escape "$CONTEXT")
echo "{\"continue\": true, \"additionalContext\": \"$CONTEXT_ESCAPED\"}"
exit 0
