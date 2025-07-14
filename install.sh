#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

error() {
    echo "[ERROR] $*" >&2
    exit 1
}

backup_file() {
    local file="$1"
    if [[ -e "$file" ]]; then
        local backup_path="$BACKUP_DIR$(dirname "$file")"
        mkdir -p "$backup_path"
        cp -L "$file" "$backup_path/" || true
        log "Backed up $file to $backup_path/"
    fi
}

create_symlink() {
    local source="$1"
    local target="$2"
    
    if [[ ! -f "$source" ]]; then
        error "Source file $source does not exist"
    fi
    
    backup_file "$target"
    
    local target_dir="$(dirname "$target")"
    if [[ ! -d "$target_dir" ]]; then
        log "Creating directory $target_dir"
        sudo mkdir -p "$target_dir"
    fi
    
    if [[ -L "$target" ]]; then
        log "Removing existing symlink $target"
        sudo rm "$target"
    elif [[ -e "$target" ]]; then
        log "Removing existing file $target"
        sudo rm "$target"
    fi
    
    log "Creating symlink $target -> $source"
    sudo ln -s "$source" "$target"
}

main() {
    local machine="${1:-}"
    
    if [[ -z "$machine" ]]; then
        error "Usage: $0 <machine-name>"
        error "Available machines: lapcat, lapdog"
    fi
    
    local machine_config="$SCRIPT_DIR/$machine.nix"
    if [[ ! -f "$machine_config" ]]; then
        error "Machine configuration $machine_config not found"
        error "Available machines: lapcat, lapdog"
    fi
    
    log "Starting configuration installation from $SCRIPT_DIR for machine: $machine"
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        error "Do not run this script as root"
    fi
    
    # Check if sudo is available
    if ! command -v sudo &> /dev/null; then
        error "sudo is required but not available"
    fi
    
    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    log "Created backup directory: $BACKUP_DIR"
    
    # NixOS system configuration
    log "Installing NixOS configuration files..."
    create_symlink "$machine_config" "/etc/nixos/configuration.nix"
    create_symlink "$SCRIPT_DIR/hardware-configuration.nix" "/etc/nixos/hardware-configuration.nix"
    
    # Home Manager configuration
    log "Installing Home Manager configuration..."
    create_symlink "$SCRIPT_DIR/home.nix" "$HOME/.config/home-manager/home.nix"
    
    # Niri configuration
    log "Installing Niri configuration..."
    create_symlink "$SCRIPT_DIR/niri.kdl" "$HOME/.config/niri/config.kdl"
    
    # Emacs configuration
    log "Installing Emacs configuration..."
    create_symlink "$SCRIPT_DIR/emacs.el" "$HOME/.emacs.d/init.el"
    
    log "Installation completed successfully for machine: $machine"
    log "Backup directory: $BACKUP_DIR"
    log ""
    log "Next steps:"
    log "  1. Run 'make switch' to apply both NixOS and Home Manager configurations"
    log "  2. Or run 'make nixos' followed by 'make home' to apply them separately"
    log "  3. Run './uninstall.sh' to remove symlinks and restore backups"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi