#!/bin/bash
# PreCompact Hook — runs BEFORE context compaction
# Creates backup of SESSION_STATE

VAULT="__VAULT_BASE__/__VAULT_NAME__"
STATE="$VAULT/03 — Активная Разработка и Детали Текущих Задач/SESSION_STATE.md"
BACKUP_DIR="$VAULT/03 — Активная Разработка и Детали Текущих Задач/_state_backups"
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

# Cleanup old backups (keep last 20)
ls -t "$BACKUP_DIR"/SESSION_STATE_*.md 2>/dev/null | tail -n +21 | xargs rm -f 2>/dev/null

echo '{"continue": true}'
exit 0
