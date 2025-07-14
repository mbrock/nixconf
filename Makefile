.PHONY: all nixos home switch

# Default target: rebuild both NixOS and Home Manager
all: switch

# Rebuild NixOS configuration
nixos:
	sudo nixos-rebuild switch

# Rebuild Home Manager configuration
home:
	home-manager switch

# Rebuild both (NixOS first, then Home Manager)
switch: nixos home

# Test NixOS configuration without switching
test:
	sudo nixos-rebuild test

# Build NixOS configuration without switching
build:
	sudo nixos-rebuild build

# Dry run for NixOS
dry-run:
	sudo nixos-rebuild dry-run

# Update NixOS channels
update:
	sudo nix-channel --update

# Garbage collection
gc:
	sudo nix-collect-garbage -d
	nix-collect-garbage -d

# Show current system generation
generation:
	sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
rollback:
	sudo nixos-rebuild switch --rollback

# Format nix files
fmt:
	nixpkgs-fmt *.nix

# Edit configurations
edit:
	$$EDITOR nixos.nix home.nix niri.kdl