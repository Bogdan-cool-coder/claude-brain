#!/bin/bash

set -e

# === Claude Brain System — Main Installer ===
# Delegates to CLI and/or Desktop installers based on user choice

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI_INSTALL="$SCRIPT_DIR/cli/install.sh"
DESKTOP_INSTALL="$SCRIPT_DIR/desktop/install.sh"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Claude Brain System — Install ===${NC}\n"

# Validate that required installers exist
if [[ ! -f "$CLI_INSTALL" ]]; then
    echo -e "${RED}✗ Error: cli/install.sh not found at $CLI_INSTALL${NC}"
    exit 1
fi

if [[ ! -f "$DESKTOP_INSTALL" ]]; then
    echo -e "${RED}✗ Error: desktop/install.sh not found at $DESKTOP_INSTALL${NC}"
    exit 1
fi

# Display menu
echo "Choose what to install:"
echo ""
echo "  1) CLI version        — Full protection (5/5 levels)"
echo "                          Hooks: SessionStart, PreCompact, PostCompact"
echo "                          Requires: Claude Code CLI"
echo ""
echo "  2) Desktop version    — Partial protection (3/5 levels)"
echo "                          Auto-backup via launchd, enhanced CLAUDE.md"
echo "                          For: Claude Desktop app Code tab"
echo ""
echo "  3) Both               — CLI + Desktop (recommended)"
echo "                          Full CLI protection + Desktop backup safety net"
echo ""
read -p "Enter choice [1/2/3]: " choice

case "$choice" in
    1)
        echo -e "\n${BLUE}Installing CLI version...${NC}\n"
        bash "$CLI_INSTALL"
        INSTALL_CLI_SUCCESS=1
        ;;
    2)
        echo -e "\n${BLUE}Installing Desktop version...${NC}\n"
        bash "$DESKTOP_INSTALL"
        INSTALL_DESKTOP_SUCCESS=1
        ;;
    3)
        echo -e "\n${BLUE}Installing CLI version...${NC}\n"
        bash "$CLI_INSTALL"
        INSTALL_CLI_SUCCESS=1

        echo ""
        echo -e "\n${BLUE}Installing Desktop version...${NC}\n"
        bash "$DESKTOP_INSTALL"
        INSTALL_DESKTOP_SUCCESS=1
        ;;
    *)
        echo -e "${RED}Invalid choice. Please enter 1, 2, or 3.${NC}"
        exit 1
        ;;
esac

# Offer to create symlink for claude-brain command if CLI was installed
if [[ $INSTALL_CLI_SUCCESS -eq 1 ]]; then
    echo ""
    echo -e "${BLUE}=== CLI Command Setup ===${NC}"
    echo ""
    read -p "Create symlink for 'claude-brain' command? (y/n) [y]: " create_symlink
    create_symlink=${create_symlink:-y}

    if [[ "$create_symlink" == "y" || "$create_symlink" == "Y" ]]; then
        BRAIN_CLI="$HOME/.claude/hooks/claude-brain"

        if [[ ! -f "$BRAIN_CLI" ]]; then
            echo -e "${RED}✗ Error: claude-brain not found at $BRAIN_CLI${NC}"
        else
            SYMLINK_PATH="/usr/local/bin/claude-brain"

            if [[ -e "$SYMLINK_PATH" ]]; then
                read -p "Symlink already exists. Overwrite? (y/n) [y]: " overwrite
                overwrite=${overwrite:-y}
                if [[ "$overwrite" != "y" && "$overwrite" != "Y" ]]; then
                    echo -e "${YELLOW}Skipped symlink creation${NC}"
                    echo ""
                    exit 0
                fi
                sudo rm "$SYMLINK_PATH"
            fi

            sudo ln -s "$BRAIN_CLI" "$SYMLINK_PATH"
            echo -e "${GREEN}✓ Symlink created: $SYMLINK_PATH → $BRAIN_CLI${NC}"
            echo ""
            echo "You can now use: ${BLUE}claude-brain${NC} from any directory"
        fi
    fi
fi

echo ""
echo -e "${GREEN}=== Installation Complete ===${NC}"
echo ""
echo "Next steps:"
echo ""

if [[ $INSTALL_CLI_SUCCESS -eq 1 ]]; then
    echo "  • CLI: Configure ~/.claude/brain-config with your Obsidian Vault path"
    echo "  • CLI: Test with: ${BLUE}claude-brain status${NC}"
fi

if [[ $INSTALL_DESKTOP_SUCCESS -eq 1 ]]; then
    echo "  • Desktop: Check ~/Library/LaunchAgents/com.claude.brain.backup.plist"
    echo "  • Desktop: Backups saved to ~/.claude/backups/"
fi

echo ""
