#!/bin/bash

# claude-brain backup-state.sh
# Runs every 5 minutes via launchd on macOS
# Backs up SESSION_STATE.md files from all projects in Obsidian Vault

set -e

# Load config
config_file="$HOME/.claude/brain-config"
if [ ! -f "$config_file" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] Config not found: $config_file" >> "$HOME/.claude/logs/backup-error.log"
    exit 1
fi

vault_root=$(grep "^vault_root=" "$config_file" | cut -d'=' -f2-)

if [ ! -d "$vault_root" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] Vault directory not found: $vault_root" >> "$HOME/.claude/logs/backup-error.log"
    exit 1
fi

# Create backup directories
backup_root="$HOME/.claude/backups"
mkdir -p "$backup_root"

timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
backed_up_count=0

# Function to check and backup a SESSION_STATE.md file
backup_state_file() {
    local state_file="$1"
    local project_name="$2"

    if [ ! -f "$state_file" ]; then
        return 0
    fi

    # Create project backup directory
    local project_backup_dir="$backup_root/$project_name"
    mkdir -p "$project_backup_dir"

    # Check if file has changed since last backup (compare with most recent backup)
    local last_backup=$(ls -t "$project_backup_dir"/SESSION_STATE_*.md 2>/dev/null | head -1)

    if [ -z "$last_backup" ]; then
        # No previous backup, always backup
        local backup_file="$project_backup_dir/SESSION_STATE_${timestamp}.md"
        cp "$state_file" "$backup_file"
        ((backed_up_count++))
    else
        # Only backup if content differs
        if ! diff -q "$state_file" "$last_backup" > /dev/null 2>&1; then
            local backup_file="$project_backup_dir/SESSION_STATE_${timestamp}.md"
            cp "$state_file" "$backup_file"
            ((backed_up_count++))
        fi
    fi

    # Keep only last 50 backups, delete older ones
    local backup_count=$(ls -1 "$project_backup_dir"/SESSION_STATE_*.md 2>/dev/null | wc -l)
    if [ "$backup_count" -gt 50 ]; then
        local to_delete=$((backup_count - 50))
        ls -t "$project_backup_dir"/SESSION_STATE_*.md | tail -n "$to_delete" | xargs rm -f
    fi
}

# Iterate through vault directories looking for SESSION_STATE.md
# Check both English and Russian folder names
for dir in "$vault_root"/*; do
    if [ ! -d "$dir" ]; then
        continue
    fi

    dir_name=$(basename "$dir")

    # v2.0 (6-folder layout)
    if [ "$dir_name" = "4. Активная работа" ]; then
        state_file="$dir/SESSION_STATE.md"
        project_name=$(basename "$(dirname "$dir")" 2>/dev/null || echo "unknown")
        backup_state_file "$state_file" "$project_name"
    fi

    # v1.x fallback: English folder name
    if [ "$dir_name" = "03 — Active Development and Current Tasks" ]; then
        state_file="$dir/SESSION_STATE.md"
        project_name=$(basename "$(dirname "$dir")" 2>/dev/null || echo "unknown")
        backup_state_file "$state_file" "$project_name"
    fi

    # v1.x fallback: Russian folder name
    if [ "$dir_name" = "03 — Активная Разработка и Детали Текущих Задач" ]; then
        state_file="$dir/SESSION_STATE.md"
        project_name=$(basename "$(dirname "$dir")" 2>/dev/null || echo "unknown")
        backup_state_file "$state_file" "$project_name"
    fi
done

# Log successful run
if [ "$backed_up_count" -gt 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') [OK] Backed up $backed_up_count file(s)" >> "$HOME/.claude/logs/backup.log"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') [OK] No changes detected" >> "$HOME/.claude/logs/backup.log"
fi

exit 0
