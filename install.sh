#!/bin/bash
# =============================================================
# Claude Brain System — One-time installer
# Run: bash install.sh
# =============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
TEMPLATES_DIR="$CLAUDE_DIR/templates"
BRAIN_CONFIG="$CLAUDE_DIR/brain-config"

echo "=== Claude Brain System — Install ==="
echo ""
echo "This will set up persistent memory for Claude Code."
echo "Claude will survive 200K token context compaction without losing track."
echo ""

# Ask for Obsidian Vault path
DEFAULT_VAULT_ROOT="$HOME/Documents/Obsidian Vault"
echo "Where is your Obsidian Vault (or folder for project vaults)?"
read -p "Path [$DEFAULT_VAULT_ROOT]: " VAULT_ROOT
VAULT_ROOT="${VAULT_ROOT:-$DEFAULT_VAULT_ROOT}"

# Expand ~ if used
VAULT_ROOT="${VAULT_ROOT/#\~/$HOME}"

if [ ! -d "$VAULT_ROOT" ]; then
  read -p "Directory doesn't exist. Create it? (y/n) " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    mkdir -p "$VAULT_ROOT"
  else
    echo "Cancelled. Create the directory first and re-run."
    exit 1
  fi
fi

# 1. Create directories
echo ""
echo "[1/5] Creating directories..."
mkdir -p "$HOOKS_DIR"
mkdir -p "$TEMPLATES_DIR"

# 2. Copy hook scripts
echo "[2/5] Installing hook scripts..."
cp "$SCRIPT_DIR/hooks/_detect-project.sh" "$HOOKS_DIR/"
cp "$SCRIPT_DIR/hooks/session-start.sh" "$HOOKS_DIR/"
cp "$SCRIPT_DIR/hooks/pre-compact.sh" "$HOOKS_DIR/"
cp "$SCRIPT_DIR/hooks/post-compact.sh" "$HOOKS_DIR/"
cp "$SCRIPT_DIR/hooks/claude-brain" "$HOOKS_DIR/"
chmod +x "$HOOKS_DIR"/*.sh "$HOOKS_DIR/claude-brain"

# 3. Copy templates
echo "[3/5] Installing templates..."
cp "$SCRIPT_DIR/templates/CLAUDE.md.template" "$TEMPLATES_DIR/"
cp "$SCRIPT_DIR/templates/SESSION_STATE.md.template" "$TEMPLATES_DIR/"

# 4. Save global config
echo "[4/5] Saving configuration..."
echo "vault_root=$VAULT_ROOT" > "$BRAIN_CONFIG"

# 5. Update settings.json
echo "[5/5] Updating ~/.claude/settings.json..."
SETTINGS="$CLAUDE_DIR/settings.json"

if [ -f "$SETTINGS" ]; then
  cp "$SETTINGS" "$SETTINGS.backup.$(date +%Y%m%d_%H%M%S)"
  echo "  Backup saved: $SETTINGS.backup.*"
fi

cp "$SCRIPT_DIR/settings.global.json" "$SETTINGS"

echo ""
echo "=== Installation Complete ==="
echo ""
echo "Global hooks:  $HOOKS_DIR/"
echo "Templates:     $TEMPLATES_DIR/"
echo "Settings:      $SETTINGS"
echo "Vault root:    $VAULT_ROOT"
echo ""
echo "Hooks now work for ALL projects automatically."
echo ""
echo "Optional: make 'claude-brain' available as a command:"
echo "  sudo ln -sf $HOOKS_DIR/claude-brain /usr/local/bin/claude-brain"
echo ""
echo "To initialize a new project:"
echo "  cd /your/project"
echo "  claude-brain init [vault-name]"
echo ""
