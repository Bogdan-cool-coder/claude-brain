#!/bin/bash
# =============================================================
# PreCompact Hook (universal) — Brain Protocol v3.0
# Runs BEFORE context compaction.
# 1) Backs up SESSION_STATE.md
# 2) Bumps compression_count deterministically (not Claude's job anymore)
# 3) Stamps last_updated
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

  # Deterministic compression_count++ (v3.0). Skip gracefully if field absent (old format).
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

# Keep last 20 backups
ls -t "$BACKUP_DIR"/SESSION_STATE_*.md 2>/dev/null | tail -n +21 | xargs rm -f 2>/dev/null

echo '{"continue": true}'
exit 0
