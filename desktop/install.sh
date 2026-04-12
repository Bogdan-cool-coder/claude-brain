#!/bin/bash

# claude-brain Desktop Version Installer
# Installs backup-state.sh via launchd for Claude Desktop app (hooks don't work)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== claude-brain Desktop Installer ===${NC}"
echo

# 1. Ask for Obsidian Vault path
read -p "Enter path to Obsidian Vault (default: ~/Documents/Obsidian Vault): " vault_path
vault_path="${vault_path:-~/Documents/Obsidian Vault}"
vault_path=$(eval echo "$vault_path")

if [ ! -d "$vault_path" ]; then
    echo -e "${RED}Error: Vault path not found: $vault_path${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Vault found at: $vault_path${NC}"
echo

# 2. Create ~/.claude directories if they don't exist
mkdir -p ~/.claude/hooks ~/.claude/templates

# 3. Save config
echo "vault_root=$vault_path" > ~/.claude/brain-config
echo -e "${GREEN}✓ Saved config to ~/.claude/brain-config${NC}"
echo

# 4. Copy backup-state.sh to ~/.claude/hooks/
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "$script_dir/backup-state.sh" ~/.claude/hooks/claude-brain-backup-state.sh
chmod +x ~/.claude/hooks/claude-brain-backup-state.sh
echo -e "${GREEN}✓ Installed backup-state.sh to ~/.claude/hooks/${NC}"
echo

# 5. Get current user
current_user=$(whoami)

# 6. Generate and install launchd plist
plist_path="$HOME/Library/LaunchAgents/com.claude-brain.backup.plist"
cat > "$plist_path" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.claude-brain.backup</string>
	<key>ProgramArguments</key>
	<array>
		<string>$HOME/.claude/hooks/claude-brain-backup-state.sh</string>
	</array>
	<key>StartInterval</key>
	<integer>300</integer>
	<key>RunAtLoad</key>
	<true/>
	<key>StandardOutPath</key>
	<string>$HOME/.claude/logs/backup.log</string>
	<key>StandardErrorPath</key>
	<string>$HOME/.claude/logs/backup-error.log</string>
	<key>UserName</key>
	<string>$current_user</string>
</dict>
</plist>
EOF

mkdir -p ~/.claude/logs
chmod 644 "$plist_path"
echo -e "${GREEN}✓ Created launchd plist at: $plist_path${NC}"
echo

# 7. Load the launchd service
launchctl load "$plist_path" 2>/dev/null || launchctl unload "$plist_path" 2>/dev/null && launchctl load "$plist_path"
echo -e "${GREEN}✓ Loaded launchd service (runs every 5 minutes)${NC}"
echo

# 8. Copy templates
if [ -d "$script_dir/../shared/templates" ]; then
    cp -r "$script_dir/../shared/templates"/* ~/.claude/templates/ 2>/dev/null || true
    echo -e "${GREEN}✓ Copied templates to ~/.claude/templates/${NC}"
else
    echo -e "${YELLOW}⚠ Templates directory not found, skipping${NC}"
fi
echo

# 9. Copy cli tool
if [ -f "$script_dir/../shared/claude-brain" ]; then
    cp "$script_dir/../shared/claude-brain" ~/.claude/hooks/claude-brain
    chmod +x ~/.claude/hooks/claude-brain
    echo -e "${GREEN}✓ Installed claude-brain CLI to ~/.claude/hooks/${NC}"
else
    echo -e "${YELLOW}⚠ claude-brain CLI not found, skipping${NC}"
fi
echo

# 10. Create/update settings.json (desktop version: compactPrompt only, no hooks)
settings_file="$HOME/.claude/settings.json"
cat > "$settings_file" << 'EOF'
{
  "compactPrompt": "When compacting context, ALWAYS preserve in summary:\n1. Path to SESSION_STATE.md (from project CLAUDE.md)\n2. Current plan step (line with → from SESSION_STATE)\n3. All changed file names in this session\n4. All decisions with reasoning\n5. Verbatim user requirements affecting current task\n6. task_id of current task\n7. Instruction: AFTER COMPACTION first read SESSION_STATE.md and CLAUDE.md section 4, then continue from step marked with →\n\nDO NOT preserve: contents of vault files (can be re-read), intermediate reasoning, code already saved to files."
}
EOF

chmod 644 "$settings_file"
echo -e "${GREEN}✓ Created settings.json at: ~/.claude/settings.json${NC}"
echo

# 11. Chmod all scripts
chmod +x ~/.claude/hooks/*.sh 2>/dev/null || true
echo -e "${GREEN}✓ Made all scripts executable${NC}"
echo

echo -e "${GREEN}=== Installation Complete ===${NC}"
echo
echo "Backup will run automatically every 5 minutes."
echo "To manually trigger a backup:"
echo "  ~/.claude/hooks/claude-brain-backup-state.sh"
echo
echo "To unload the launchd service:"
echo "  launchctl unload ~/Library/LaunchAgents/com.claude-brain.backup.plist"
echo
echo "Backup logs:"
echo "  ~/.claude/logs/backup.log"
echo "  ~/.claude/logs/backup-error.log"
