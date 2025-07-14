# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository contains NixOS and Home Manager configuration files for a personal desktop environment setup. The system uses:
- **NixOS** for system-level configuration
- **Home Manager** for user-level configuration  
- **Niri** as the Wayland compositor
- **Emacs** as the primary editor with LSP Bridge and Prolog support

## Development Commands

### System Management
```bash
# Rebuild both NixOS and Home Manager configurations
make switch

# Rebuild only NixOS configuration
make nixos
# Alternative: sudo nixos-rebuild switch

# Rebuild only Home Manager configuration  
make home
# Alternative: home-manager switch

# Test NixOS configuration without applying
make test
# Alternative: sudo nixos-rebuild test

# Build configuration without switching
make build
# Alternative: sudo nixos-rebuild build

# Preview changes without applying
make dry-run
# Alternative: sudo nixos-rebuild dry-run
```

### Maintenance
```bash
# Update system channels
make update

# Garbage collection
make gc

# Show system generations
make generation

# Rollback to previous generation
make rollback

# Format Nix files
make fmt
# Uses nixpkgs-fmt on *.nix files

# Edit main configurations
make edit
# Opens nixos.nix, home.nix, and niri.kdl in $EDITOR
```

## Architecture

### Core Configuration Files
- **nixos.nix**: System-level NixOS configuration including packages, services, and hardware
- **home.nix**: User-level Home Manager configuration for packages and dotfiles
- **hardware-configuration.nix**: Hardware-specific NixOS configuration (auto-generated)
- **niri.kdl**: Niri window manager configuration with keybindings and layout settings
- **emacs.el**: Emacs configuration with LSP Bridge, Prolog, and Lisp support

### Key Features
- **Cross-platform clipboard**: Custom scripts for syncing clipboard between Wayland and macOS via SSH
- **Development environment**: Pre-configured with Node.js, Python (uv), Git, Make, and language servers
- **Window management**: Niri compositor with tiling layout and custom keybindings
- **Text editing**: Emacs with LSP Bridge, SWI-Prolog, and Common Lisp (SLY) support

### System Services
- SSH server enabled on port 22
- Tailscale VPN
- Auto-login via greetd
- VMware guest tools (for virtualized environments)

## File Editing Guidelines
- Always format Nix files with `nixpkgs-fmt` after editing
- Test configurations with `make test` before switching
- Use `make dry-run` to preview changes
- The system uses Dvorak keyboard layout with caps lock as control