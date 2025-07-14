#!/usr/bin/env bash

set -euo pipefail

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

error() {
    echo "[ERROR] $*" >&2
    exit 1
}

remove_symlink() {
    local target="$1"
    
    if [[ -L "$target" ]]; then
        log "Removing symlink $target"
        sudo rm "$target"
    elif [[ -e "$target" ]]; then
        log "Warning: $target exists but is not a symlink, skipping"
    else
        log "Symlink $target does not exist, skipping"
    fi
}

restore_backup() {
    local backup_dir="$1"
    
    if [[ ! -d "$backup_dir" ]]; then
        log "Backup directory $backup_dir not found, skipping restore"
        return
    fi
    
    log "Restoring files from $backup_dir"
    
    # Find all files in backup directory and restore them
    find "$backup_dir" -type f | while read -r backup_file; do
        # Get relative path from backup directory
        local rel_path="${backup_file#$backup_dir}"
        local original_path="$rel_path"
        
        if [[ -f "$backup_file" ]]; then
            local target_dir="$(dirname "$original_path")"
            if [[ ! -d "$target_dir" ]]; then
                sudo mkdir -p "$target_dir"
            fi
            
            log "Restoring $original_path"
            sudo cp "$backup_file" "$original_path"
        fi
    done
}

main() {
    log "Starting configuration uninstallation"
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        error "Do not run this script as root"
    fi
    
    # Check if sudo is available
    if ! command -v sudo &> /dev/null; then
        error "sudo is required but not available"
    fi
    
    # Remove symlinks
    log "Removing configuration symlinks..."
    
    remove_symlink "/etc/nixos/configuration.nix"
    remove_symlink "/etc/nixos/hardware-configuration.nix"
    remove_symlink "$HOME/.config/home-manager/home.nix"
    remove_symlink "$HOME/.config/niri/config.kdl"
    remove_symlink "$HOME/.emacs.d/init.el"
    
    # Ask about backup restoration
    if [[ "${1:-}" == "--restore-backup" ]]; then
        if [[ -n "${2:-}" ]]; then
            restore_backup "$2"
        else
            # Find most recent backup
            local latest_backup
            latest_backup=$(find "$HOME" -maxdepth 1 -name ".config-backup-*" -type d | sort | tail -n1)
            if [[ -n "$latest_backup" ]]; then
                log "Found backup directory: $latest_backup"
                read -p "Restore backup? (y/N): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    restore_backup "$latest_backup"
                fi
            else
                log "No backup directory found"
            fi
        fi
    fi
    
    log "Uninstallation completed!"
    log ""
    log "Usage:"
    log "  ./uninstall.sh                    # Remove symlinks only"
    log "  ./uninstall.sh --restore-backup   # Remove symlinks and restore latest backup"
    log "  ./uninstall.sh --restore-backup /path/to/backup  # Restore specific backup"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi