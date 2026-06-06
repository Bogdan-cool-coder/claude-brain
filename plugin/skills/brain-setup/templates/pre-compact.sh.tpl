#!/bin/bash
# PreCompact Hook (Brain Protocol v3.0) — runs BEFORE context compaction.
# Backs up SESSION_STATE, bumps compression_count deterministically, stamps last_updated.

VAULT="__VAULT_BASE__/__VAULT_NAME__"
STATE="$VAULT/4. Активная работа/SESSION_STATE.md"
BACKUP_DIR="$VAULT/4. Активная работа/_state_backups"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

mkdir -p "$BACKUP_DIR"

if [ -f "$STATE" ]; then
  cp "$STATE" "$BACKUP_DIR/SESSION_STATE_$TIMESTAMP.md"

  # compression_count++ (deterministic). Skip if absent (old format).
  if grep -q "^compression_count:" "$STATE" 2>/dev/null; then
    CC=$(grep "^compression_count:" "$STATE" | head -1 | sed 's/[^0-9]*//g')
    CC=${CC:-0}
    NEWCC=$((CC + 1))
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' "s/^compression_count:.*/compression_count: $NEWCC/" "$STATE"
    else
      sed -i "s/^compression_count:.*/compression_count: $NEWCC/" "$STATE"
    fi
  fi

  # Stamp last_updated
  if grep -q "^last_updated:" "$STATE" 2>/dev/null; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' "s/^last_updated:.*/last_updated: $(date +"%Y-%m-%d %H:%M") (pre-compact)/" "$STATE"
    else
      sed -i "s/^last_updated:.*/last_updated: $(date +"%Y-%m-%d %H:%M") (pre-compact)/" "$STATE"
    fi
  fi
fi

# Cleanup old backups (keep last 20)
ls -t "$BACKUP_DIR"/SESSION_STATE_*.md 2>/dev/null | tail -n +21 | xargs rm -f 2>/dev/null

echo '{"continue": true}'
exit 0
