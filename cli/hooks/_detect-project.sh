#!/bin/bash
# =============================================================
# _detect-project.sh — shared helper for all hooks
# Auto-detects project name, vault path from current directory
# Source: source "$(dirname "$0")/_detect-project.sh"
# =============================================================

# Read global config
BRAIN_CONFIG="$HOME/.claude/brain-config"
if [ -f "$BRAIN_CONFIG" ]; then
  OBSIDIAN_VAULT_ROOT=$(grep "^vault_root=" "$BRAIN_CONFIG" | head -1 | cut -d'=' -f2-)
fi
OBSIDIAN_VAULT_ROOT="${OBSIDIAN_VAULT_ROOT:-$HOME/Documents/Obsidian Vault}"

# Detect project root (git root or current dir)
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
PROJECT_DIR_NAME=$(basename "$PROJECT_ROOT")

# Check project-specific config (.claude/brain.conf)
# Allows overriding vault name per project
BRAIN_CONF="$PROJECT_ROOT/.claude/brain.conf"
if [ -f "$BRAIN_CONF" ]; then
  VAULT_NAME=$(grep "^vault_name=" "$BRAIN_CONF" 2>/dev/null | head -1 | cut -d'=' -f2-)
fi

# Fallback to directory name
VAULT_NAME="${VAULT_NAME:-$PROJECT_DIR_NAME}"

# Build paths
VAULT="$OBSIDIAN_VAULT_ROOT/$VAULT_NAME"

# v2.0 (6-folder): "4. Активная работа/"
# v1.x (11-folder): "03 — Активная Разработка и Детали Текущих Задач/"
if [ -d "$VAULT/4. Активная работа" ]; then
  STATE="$VAULT/4. Активная работа/SESSION_STATE.md"
  BACKUP_DIR="$VAULT/4. Активная работа/_state_backups"
elif [ -d "$VAULT/03 — Активная Разработка и Детали Текущих Задач" ]; then
  STATE="$VAULT/03 — Активная Разработка и Детали Текущих Задач/SESSION_STATE.md"
  BACKUP_DIR="$VAULT/03 — Активная Разработка и Детали Текущих Задач/_state_backups"
else
  # Default to v2.0 layout
  STATE="$VAULT/4. Активная работа/SESSION_STATE.md"
  BACKUP_DIR="$VAULT/4. Активная работа/_state_backups"
fi

# JSON escape helper
json_escape() {
  echo "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g' | tr '\n' ' '
}
