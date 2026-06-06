#!/bin/bash
# =============================================================
# SessionStart Hook (universal) — Brain Protocol v3.0
# Runs on EVERY Claude Code session start.
# Reminds Claude to read SESSION_STATE.md first + parallel-session guard.
# =============================================================

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$HOOK_DIR/_detect-project.sh"

# No vault for this project — skip silently
if [ ! -d "$VAULT" ]; then
  echo '{"continue": true}'
  exit 0
fi

CONTEXT="SESSION START [$VAULT_NAME]. READ FIRST: 1) SESSION_STATE.md: $STATE 2) Continuity block in CLAUDE.md (раздел 🧠 Continuity)."

if [ -f "$STATE" ]; then
  TASK_ID=$(grep "^task_id:" "$STATE" 2>/dev/null | head -1 | sed 's/^task_id: *//' | tr -d '"')
  LAST_UPDATED=$(grep "^last_updated:" "$STATE" 2>/dev/null | head -1 | sed 's/^last_updated: *//')
  SESSION_LABEL=$(grep "^session_label:" "$STATE" 2>/dev/null | head -1 | sed 's/^session_label: *//' | tr -d '"')

  # Single canonical anchor (v3.0) with backward-compatible fallbacks (v2.0)
  CURRENT_STEP=$(grep "^→ Следующий шаг:" "$STATE" 2>/dev/null | head -1)
  [ -z "$CURRENT_STEP" ] && CURRENT_STEP=$(grep "^→" "$STATE" 2>/dev/null | head -1)

  [ -n "$TASK_ID" ] && CONTEXT="$CONTEXT TASK: $TASK_ID."
  [ -n "$LAST_UPDATED" ] && CONTEXT="$CONTEXT UPDATED: $LAST_UPDATED."
  [ -n "$CURRENT_STEP" ] && CONTEXT="$CONTEXT CURRENT STEP: $CURRENT_STEP"

  # --- Parallel-session guard (time-based, v3.0) ---
  # If STATE was updated very recently, another session may be active.
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
        CONTEXT="$CONTEXT ⚠ PARALLEL-GUARD: STATE обновлён ${DIFF} мин назад (session_label: ${SESSION_LABEL:-?}). Возможна параллельная сессия — НЕ затирай STATE вслепую, при сомнении уточни. SESSION_STATE один, дубль не создавать."
      fi
    fi
  fi
else
  CONTEXT="$CONTEXT WARNING: SESSION_STATE.md not found. Create from template (skill brain-setup / brain-protocol)."
fi

CONTEXT_ESCAPED=$(json_escape "$CONTEXT")
echo "{\"continue\": true, \"additionalContext\": \"$CONTEXT_ESCAPED\"}"
exit 0
