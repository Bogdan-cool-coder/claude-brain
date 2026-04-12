#!/bin/bash
# =============================================================
# PreCompact Hook (universal)
# Runs BEFORE context compaction
# Backs up SESSION_STATE.md
# =============================================================

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$HOOK_DIR/_detect-project.sh"

# No vault — skip
if [ ! -d "$VAULT" ]; then
  echo '{"continue": true}'
  exit 0
fi

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

mkdir -p "$BACKUP_DIR"

if [ -f "$STATE" ]; then
  cp "$STATE" "$BACKUP_DIR/SESSION_STATE_$TIMESTAMP.md"

  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/^last_updated:.*/last_updated: $(date +"%Y-%m-%d %H:%M") (pre-compact backup)/" "$STATE"
  else
    sed -i "s/^last_updated:.*/last_updated: $(date +"%Y-%m-%d %H:%M") (pre-compact backup)/" "$STATE"
  fi
fi

# Keep last 20 backups
ls -t "$BACKUP_DIR"/SESSION_STATE_*.md 2>/dev/null | tail -n +21 | xargs rm -f 2>/dev/null

echo '{"continue": true}'
exit 0
