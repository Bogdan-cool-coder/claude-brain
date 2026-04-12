#!/bin/bash
# =============================================================
# SessionStart Hook (universal)
# Runs on EVERY Claude Code session start
# Reminds Claude to read SESSION_STATE.md first
# =============================================================

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$HOOK_DIR/_detect-project.sh"

# No vault for this project — skip silently
if [ ! -d "$VAULT" ]; then
  echo '{"continue": true}'
  exit 0
fi

CONTEXT="SESSION START [$VAULT_NAME]. READ FIRST: 1) SESSION_STATE.md: $STATE 2) Section 4 of CLAUDE.md (continuity protocol)."

if [ -f "$STATE" ]; then
  TASK_ID=$(grep "^task_id:" "$STATE" 2>/dev/null | head -1 | sed 's/^task_id: *//' | tr -d '"')
  CURRENT_STEP=$(grep "^→" "$STATE" 2>/dev/null | head -1)
  LAST_UPDATED=$(grep "^last_updated:" "$STATE" 2>/dev/null | head -1 | sed 's/^last_updated: *//')

  [ -n "$TASK_ID" ] && CONTEXT="$CONTEXT TASK: $TASK_ID."
  [ -n "$LAST_UPDATED" ] && CONTEXT="$CONTEXT UPDATED: $LAST_UPDATED."
  [ -n "$CURRENT_STEP" ] && CONTEXT="$CONTEXT CURRENT STEP: $CURRENT_STEP"
else
  CONTEXT="$CONTEXT WARNING: SESSION_STATE.md not found. Create from template in CLAUDE.md section 4."
fi

CONTEXT_ESCAPED=$(json_escape "$CONTEXT")
echo "{\"continue\": true, \"additionalContext\": \"$CONTEXT_ESCAPED\"}"
exit 0
