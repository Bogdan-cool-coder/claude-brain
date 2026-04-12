#!/bin/bash
# =============================================================
# PostCompact Hook (universal)
# Runs AFTER context compaction
# Injects full recovery context into Claude
# =============================================================

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$HOOK_DIR/_detect-project.sh"

# No vault — skip
if [ ! -d "$VAULT" ]; then
  echo '{"continue": true}'
  exit 0
fi

CONTEXT="CONTEXT COMPACTED [$VAULT_NAME]. REQUIRED: 1) Read SESSION_STATE.md: $STATE 2) Read CLAUDE.md section 4 3) Find line with → in plan 4) Increment compression_count 5) Continue from that step. FORBIDDEN: asking what we were doing, retelling, changing plan. FIRST MESSAGE = Next — [action]."

if [ -f "$STATE" ]; then
  TASK_ID=$(grep "^task_id:" "$STATE" 2>/dev/null | head -1 | sed 's/^task_id: *//' | tr -d '"')
  CURRENT_STEP=$(grep "^→" "$STATE" 2>/dev/null | head -1)
  NEXT_ACTION=$(sed -n '/^## Следующее действие/,/^##/p' "$STATE" 2>/dev/null | grep -v "^##" | head -1 | sed 's/^ *//')
  # Fallback to English header
  if [ -z "$NEXT_ACTION" ]; then
    NEXT_ACTION=$(sed -n '/^## Next Action/,/^##/p' "$STATE" 2>/dev/null | grep -v "^##" | head -1 | sed 's/^ *//')
  fi

  [ -n "$TASK_ID" ] && CONTEXT="$CONTEXT TASK: $TASK_ID."
  [ -n "$CURRENT_STEP" ] && CONTEXT="$CONTEXT CURRENT STEP: $CURRENT_STEP"
  [ -n "$NEXT_ACTION" ] && CONTEXT="$CONTEXT NEXT: $NEXT_ACTION"
else
  CONTEXT="$CONTEXT WARNING: SESSION_STATE.md not found. Create immediately."
fi

CONTEXT_ESCAPED=$(json_escape "$CONTEXT")
echo "{\"continue\": true, \"additionalContext\": \"$CONTEXT_ESCAPED\"}"
exit 0
