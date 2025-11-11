.PHONY: all nixos home switch

# Default target: rebuild system with flake (includes NixOS + Home Manager)
all: switch

# Rebuild NixOS configuration (flake-based, includes Home Manager)
nixos:
	sudo nixos-rebuild switch --flake .#lapland

# Rebuild Home Manager configuration (now integrated via flake)
home:
	sudo nixos-rebuild switch --flake .#lapland

# Rebuild both (NixOS + Home Manager via flake)
switch:
	sudo nixos-rebuild switch --flake .#lapland -L

# Test NixOS configuration without switching
test:
	sudo nixos-rebuild test --flake .#lapland

# Build NixOS configuration without switching
build:
	sudo nixos-rebuild build --flake .#lapland

# Dry run for NixOS
dry-run:
	sudo nixos-rebuild dry-run --flake .#lapland

# Update flake inputs
update:
	nix flake update

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
	find . -name '*.nix' -type f | xargs nix fmt

# Edit configurations
edit:
	$$EDITOR nixos.nix home.nix niri.kdl
