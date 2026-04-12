#!/bin/bash

set -e

# === Claude Brain System — CLI Installer ===
# Installs hooks, templates, and configuration for Claude Code CLI
# Run from: parent directory or directly as: bash cli/install.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
TEMPLATES_DIR="$CLAUDE_DIR/templates"
BRAIN_CONFIG="$CLAUDE_DIR/brain-config"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Claude Brain CLI — Installer ===${NC}\n"

echo "This will install hooks and templates for Claude Code CLI."
echo "Full protection: SessionStart, PreCompact, PostCompact hooks."
echo ""

# Determine parent directory (where shared/ and cli/ directories are)
PARENT_DIR="$(dirname "$SCRIPT_DIR")"

# Validate required directories and files
echo "[1/6] Validating installation source..."
required_files=(
    "$SCRIPT_DIR/hooks/_detect-project.sh"
    "$SCRIPT_DIR/hooks/session-start.sh"
    "$SCRIPT_DIR/hooks/pre-compact.sh"
    "$SCRIPT_DIR/hooks/post-compact.sh"
    "$PARENT_DIR/shared/claude-brain"
    "$PARENT_DIR/shared/templates/CLAUDE.cli.md.template"
    "$PARENT_DIR/shared/templates/SESSION_STATE.md.template"
    "$SCRIPT_DIR/settings.json"
)

for file in "${required_files[@]}"; do
    if [[ ! -f "$file" ]]; then
        echo -e "${RED}✗ Error: Required file not found: $file${NC}"
        exit 1
    fi
done

echo -e "${GREEN}✓ All source files found${NC}\n"

# Ask for Obsidian Vault path
echo "[2/6] Configuring Obsidian Vault path..."
DEFAULT_VAULT="$HOME/Documents/Obsidian Vault"

if [[ -f "$BRAIN_CONFIG" && -z "$VAULT_ROOT" ]]; then
    EXISTING_VAULT=$(grep "^vault_root=" "$BRAIN_CONFIG" | cut -d'=' -f2-)
    if [[ -n "$EXISTING_VAULT" ]]; then
        DEFAULT_VAULT="$EXISTING_VAULT"
        echo "Found existing vault path in config: $DEFAULT_VAULT"
    fi
fi

read -p "Obsidian Vault path [$DEFAULT_VAULT]: " VAULT_ROOT
VAULT_ROOT="${VAULT_ROOT:-$DEFAULT_VAULT}"

# Expand ~ if used
VAULT_ROOT="${VAULT_ROOT/#\~/$HOME}"

# Validate vault directory
if [[ ! -d "$VAULT_ROOT" ]]; then
    echo ""
    read -p "Directory doesn't exist. Create it? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        mkdir -p "$VAULT_ROOT"
        echo -e "${GREEN}✓ Created: $VAULT_ROOT${NC}"
    else
        echo -e "${YELLOW}Cancelled. Create the directory first and re-run.${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✓ Vault configured: $VAULT_ROOT${NC}\n"

# Create directories
echo "[3/6] Creating directories..."
mkdir -p "$HOOKS_DIR"
mkdir -p "$TEMPLATES_DIR"
mkdir -p "$CLAUDE_DIR/backups"

echo -e "${GREEN}✓ Directories created:${NC}"
echo "  $HOOKS_DIR"
echo "  $TEMPLATES_DIR"
echo "  $CLAUDE_DIR/backups"
echo ""

# Copy hook scripts
echo "[4/6] Installing hook scripts..."
cp "$SCRIPT_DIR/hooks/_detect-project.sh" "$HOOKS_DIR/"
cp "$SCRIPT_DIR/hooks/session-start.sh" "$HOOKS_DIR/"
cp "$SCRIPT_DIR/hooks/pre-compact.sh" "$HOOKS_DIR/"
cp "$SCRIPT_DIR/hooks/post-compact.sh" "$HOOKS_DIR/"
cp "$PARENT_DIR/shared/claude-brain" "$HOOKS_DIR/"

chmod +x "$HOOKS_DIR"/_detect-project.sh
chmod +x "$HOOKS_DIR"/session-start.sh
chmod +x "$HOOKS_DIR"/pre-compact.sh
chmod +x "$HOOKS_DIR"/post-compact.sh
chmod +x "$HOOKS_DIR"/claude-brain

echo -e "${GREEN}✓ Hook scripts installed and made executable:${NC}"
echo "  _detect-project.sh"
echo "  session-start.sh"
echo "  pre-compact.sh"
echo "  post-compact.sh"
echo "  claude-brain (utility)"
echo ""

# Copy templates
echo "[5/6] Installing templates..."
cp "$PARENT_DIR/shared/templates/CLAUDE.cli.md.template" "$TEMPLATES_DIR/"
cp "$PARENT_DIR/shared/templates/SESSION_STATE.md.template" "$TEMPLATES_DIR/"

echo -e "${GREEN}✓ Templates installed:${NC}"
echo "  CLAUDE.cli.md.template"
echo "  SESSION_STATE.md.template"
echo ""

# Save configuration
echo "[6/6] Saving configuration..."

# Update brain-config
echo "vault_root=$VAULT_ROOT" > "$BRAIN_CONFIG"
echo "hooks_dir=$HOOKS_DIR" >> "$BRAIN_CONFIG"
echo "templates_dir=$TEMPLATES_DIR" >> "$BRAIN_CONFIG"
echo "installed_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$BRAIN_CONFIG"
echo "version=1.0" >> "$BRAIN_CONFIG"

# Backup and update settings.json
SETTINGS="$CLAUDE_DIR/settings.json"
if [[ -f "$SETTINGS" ]]; then
    BACKUP_FILE="$SETTINGS.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$SETTINGS" "$BACKUP_FILE"
    echo -e "${YELLOW}  Backup saved: $BACKUP_FILE${NC}"
fi

cp "$SCRIPT_DIR/settings.json" "$SETTINGS"

echo -e "${GREEN}✓ Configuration saved:${NC}"
echo "  $BRAIN_CONFIG"
echo "  $SETTINGS"
echo ""

# Final summary
echo -e "${GREEN}=== Installation Complete ===${NC}\n"

echo "Installed components:"
echo "  ✓ 4 hook scripts (SessionStart, PreCompact, PostCompact, ProjectDetect)"
echo "  ✓ Templates for CLAUDE.md and SESSION_STATE.md"
echo "  ✓ CLI utility (claude-brain)"
echo "  ✓ Configuration and settings"
echo ""

echo "Configuration details:"
echo "  Vault root:    $VAULT_ROOT"
echo "  Hooks:         $HOOKS_DIR"
echo "  Templates:     $TEMPLATES_DIR"
echo "  Settings:      $SETTINGS"
echo ""

echo "Next steps:"
echo "  1. Test hooks with: ${BLUE}cd /your/project && claude-brain status${NC}"
echo "  2. Create symlink (optional): ${BLUE}sudo ln -s $HOOKS_DIR/claude-brain /usr/local/bin/claude-brain${NC}"
echo "  3. Initialize a project: ${BLUE}claude-brain init [vault-name]${NC}"
echo ""

echo "Documentation:"
echo "  • Main README: $PARENT_DIR/README.md"
echo "  • Hooks guide: $PARENT_DIR/docs/hooks.md (if available)"
echo ""
