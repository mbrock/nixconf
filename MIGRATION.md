# Migrating from Home Manager to Pure NixOS

## What Changed

I've created a simplified NixOS configuration that removes Home Manager and agenix dependencies:

### Removed:
- Home Manager module system
- Agenix secret management 
- The `nt` service (Node.Town server)
- Unnecessary complexity

### Migrated to NixOS:
- User packages → `environment.systemPackages`
- Bash aliases → `programs.bash`
- Starship prompt → `programs.starship`
- Direnv → `programs.direnv`
- Kitty config → `/etc/xdg/kitty/kitty.conf`
- Mako notifications → systemd user service
- NPM config → `/etc/npmrc`
- Session variables → `environment.sessionVariables`

## Files Created

- `flake-nohm.nix` - Simplified flake without Home Manager
- `nixos-simple.nix` - Combined NixOS configuration
- `Makefile-simple` - Build commands for the new setup

## How to Switch

1. **Test the new configuration first:**
   ```bash
   # First, backup your current generation number
   sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -1
   
   # Build without switching to test
   sudo nixos-rebuild build -I nixos-config=/home/mbrock/conf/nixos-simple.nix
   ```

2. **If build succeeds, switch to it:**
   ```bash
   sudo nixos-rebuild switch -I nixos-config=/home/mbrock/conf/nixos-simple.nix
   ```

3. **If something goes wrong, rollback:**
   ```bash
   sudo nixos-rebuild switch --rollback
   ```

4. **Once happy, replace the old files:**
   ```bash
   mv flake.nix flake-old.nix
   mv flake-nohm.nix flake.nix
   mv nixos-base.nix nixos-base-old.nix  
   mv nixos-simple.nix nixos-base.nix
   mv Makefile Makefile-old
   mv Makefile-simple Makefile
   
   # Remove Home Manager config
   rm home.nix service.nix
   ```

## What You Lose

- Per-user package management (everything is system-wide now)
- Declarative secret management (you'll need to manage API keys manually)
- Home Manager's more granular control over user configs

## What You Gain

- Simpler configuration
- Faster rebuilds
- Less abstraction layers
- No Home Manager state to manage