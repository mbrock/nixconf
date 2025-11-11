{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ./hardware-configuration.nix ];

  hardware.graphics.enable = true;

  environment.systemPackages = with pkgs; [
    waybar
    kitty
    ((emacsPackagesFor emacs-pgtk).emacsWithPackages (
      e: with e; [
        # Core packages
        use-package

        # Version control
        magit
        diff-hl

        # Completion & minibuffer
        vertico
        orderless
        consult
        embark
        marginalia
        company

        # Language support
        nix-mode
        paredit
        sly
        cmake-mode
        meson-mode
        llvm-mode

        # Environment & tools
        envrc
        eat

        # UI enhancements
        rainbow-delimiters
        which-key
        dired-hide-dotfiles

        # Treesit grammars for better syntax highlighting
        (treesit-grammars.with-grammars (
          gs: with gs; [
            tree-sitter-bash
            tree-sitter-c
            tree-sitter-cpp
            tree-sitter-cmake
            tree-sitter-nix
            tree-sitter-python
            tree-sitter-rust
            tree-sitter-javascript
            tree-sitter-typescript
            tree-sitter-json
            tree-sitter-yaml
            tree-sitter-toml
          ]
        ))
      ]
    ))
#    sbcl
#    nodejs_24
    git
#    uv
    gnumake

    # Language servers for eglot
    nixd
    clang-tools # provides clangd
    cmake-language-server
    mesonlsp
    llvmPackages.mlir # provides mlir-lsp-server for LLVM IR

    xwayland-satellite
    swayimg
    wl-clipboard
    libnotify
#    chromium
    ripgrep
     swaybg
    claude-code

    # Terminal wrapper
    (writeShellScriptBin "term" ''
      exec ${xterm}/bin/xterm \
        -fa "Iosevka Term Extended" \
        -fs 26 \
        -bg "#000000" \
        -fg "#ffffff" \
        -b 8 \
        +sb \
        "$@"
    '')

    # Build script for make with conditional window behavior
    (writeShellScriptBin "conf-build" ''
      cd ~/conf
      echo "Building configuration..."
      if make; then
        exit 0
      else
        echo "❌ Build failed!"
        echo "Press any key to close..."
        read -n 1
        exit 1
      fi
    '')

    # Git helper scripts
    (writeShellScriptBin "git-summary" ''
      echo -n "<`whoami`> "
      if test `git status --short | wc -l` = 1
      then echo `git status --short` `git shortstat | sed 's,1 file changed ,,'`
      else git shortstat
      fi
    '')

    (writeShellScriptBin "git-shortstat" ''
      git diff HEAD --shortstat | cut -c2- | sed s/,//g |
      sed -E 's/([0-9]+) insertions?\(\+\)/+\1/' |
      sed -E 's/([0-9]+) deletions?\(-\)/-\1/' |
      sed -E 's/\+([0-9]+) -([0-9]+)/+\1\/-\2/' |
      sed -E 's/([^ ]+)$/(\1)/'
    '')

    (writeShellScriptBin "git-save" ''
      git add -A
      git diff HEAD --quiet || git summary | git commit -F-
    '')

    # Clipboard integration scripts
    (writeShellScriptBin "copy-to-mac" ''
      # Copy from Wayland clipboard to macOS clipboard
      content=$(${wl-clipboard}/bin/wl-paste 2>/dev/null || echo "")

      if [ -z "$content" ]; then
        ${libnotify}/bin/notify-send -t 2000 -u critical "❌ Copy Failed" "No content in clipboard"
        exit 1
      fi

      if echo "$content" | ssh mikaels-mac-mini-2 pbcopy; then
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

  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Riga";

  i18n.defaultLocale = "en_US.UTF-8";
  console.font = "Lat2-Terminus16";
  console.useXkbConfig = true;
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.variant = "dvorak";
  services.xserver.xkb.options = "ctrl:nocaps";

  fonts.packages = with pkgs; [
 #   nerd-fonts.iosevka
 #   iosevka
 #   font-awesome
    jetbrains-mono
#    input-fonts
  ];

  fonts.fontconfig.enable = true;
  fonts.fontconfig.hinting.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.input-fonts.acceptLicense = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  users.users.mbrock = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJD7B4saBw7XXHcNMeO8MVudPSUDWwzje5y0lLQPP7Ub mikael@brockman.se"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "25.05"; # never change or delete

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
