{ config, lib, pkgs, ... }:

{
  imports = [./hardware-configuration.nix];

  environment.systemPackages = with pkgs; [
    vim alacritty waybar 
    ((emacsPackagesFor emacs-pgtk).emacsWithPackages (
      e: with e; [
        nix-mode paredit lsp-bridge sweeprolog sly
      ]))
    sbcl
    nodejs_24
    git
    uv
    gnumake
    nixd
    swi-prolog-gui
    xwayland-satellite
    swayimg
    wl-clipboard
    libnotify
    chromium
    ripgrep
    
    # Build script for make with conditional window behavior
    (writeShellScriptBin "conf-build" ''
      cd ~/conf
      echo "Building configuration..."
      if make; then
        sleep 2
        exit 0
      else
        echo "❌ Build failed!"
        echo "Press any key to close..."
        read -n 1
        exit 1
      fi
    '')

    # Clipboard integration scripts
    (writeShellScriptBin "copy-to-mac" ''
      # Copy from Wayland clipboard to macOS clipboard
      content=$(${wl-clipboard}/bin/wl-paste 2>/dev/null || echo "")
      
      if [ -z "$content" ]; then
        ${libnotify}/bin/notify-send -t 2000 -u critical "❌ Copy Failed" "No content in clipboard"
        exit 1
      fi
      
      if echo "$content" | ssh mikaels-macbook-air pbcopy; then
        # Check if content is text and create preview
        if echo "$content" | grep -q "[^[:print:][:space:]]"; then
          preview="(binary content)"
        else
          # Truncate to 50 chars and add ellipsis if needed
          preview=$(echo "$content" | tr '\n' ' ' | sed 's/[[:space:]]\+/ /g' | cut -c1-50)
          if [ ''${#content} -gt 50 ]; then
            preview="$preview..."
          fi
        fi
        ${libnotify}/bin/notify-send -t 2000 "📋 Copied to Mac" "$preview"
      else
        ${libnotify}/bin/notify-send -t 2000 -u critical "❌ Copy Failed" "Could not sync to macOS clipboard"
      fi
    '')
    
    (writeShellScriptBin "paste-from-mac" ''
      # Paste from macOS clipboard to Wayland clipboard
      content=$(ssh mikaels-macbook-air pbpaste 2>/dev/null || echo "")
      
      if [ -z "$content" ]; then
        ${libnotify}/bin/notify-send -t 2000 -u critical "❌ Paste Failed" "No content in macOS clipboard"
        exit 1
      fi
      
      if echo "$content" | ${wl-clipboard}/bin/wl-copy; then
        # Check if content is text and create preview
        if echo "$content" | grep -q "[^[:print:][:space:]]"; then
          preview="(binary content)"
        else
          # Truncate to 50 chars and add ellipsis if needed
          preview=$(echo "$content" | tr '\n' ' ' | sed 's/[[:space:]]\+/ /g' | cut -c1-50)
          if [ ''${#content} -gt 50 ]; then
            preview="$preview..."
          fi
        fi
        ${libnotify}/bin/notify-send -t 2000 "📋 Pasted from Mac" "$preview"
      else
        ${libnotify}/bin/notify-send -t 2000 -u critical "❌ Paste Failed" "Could not sync from macOS clipboard"
      fi
    '')
  ];

  programs.niri.enable = true;
  programs.nix-ld.enable = true;

  # Configure greetd for autologin
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd niri-session";
        user = "greeter";
      };
      initial_session = {
        command = "niri-session";
        user = "mbrock";
      };
    };
  };

  services.openssh.enable = true;
  services.tailscale.enable = true;

  networking.firewall.allowedTCPPorts = [ 22 ];
  
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "lapcat";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Riga";

  i18n.defaultLocale = "en_US.UTF-8";
  console.font = "Lat2-Terminus16";
  console.useXkbConfig = true;
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.variant = "dvorak";
  services.xserver.xkb.options = "ctrl:nocaps";

  fonts.packages = with pkgs; [
    nerd-fonts.iosevka iosevka font-awesome
    jetbrains-mono input-fonts
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.input-fonts.acceptLicense = true;

  users.users.mbrock = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJD7B4saBw7XXHcNMeO8MVudPSUDWwzje5y0lLQPP7Ub mikael@brockman.se
"
    ];
  };


  virtualisation.vmware.guest.enable = true;

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "25.05"; # never change or delete
}

