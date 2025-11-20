{
  config,
  lib,
  pkgs,
  nom,
  ...
}:

{

  hardware.graphics.enable = true;

  # Combined system and user packages
  environment.systemPackages = with pkgs; [
    nom.packages.${pkgs.system}.default
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
    git
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
    ripgrep
    swaybg

    # Additional packages from Home Manager
    font-manager

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
      git save
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

  # System-wide programs
  programs.niri.enable = true;
  programs.nix-ld.enable = true;
  programs.direnv.enable = true;
  programs.starship.enable = true;

  # Bash configuration system-wide
  programs.bash = {
    interactiveShellInit = ''
      alias ls='ls --color=auto'
      alias grep='grep --color=auto'
    '';
  };

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
    jetbrains-mono
  ];

  fonts.fontconfig.enable = true;
  fonts.fontconfig.hinting.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.input-fonts.acceptLicense = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    download-buffer-size = 64 * 1024 * 1024;  # 64MB
    builders-use-substitutes = true;
  };

  nix.buildMachines = [
    {
      hostName = "igloo";
      systems = [ "x86_64-linux" "aarch64-linux" ];
      maxJobs = 4;
      speedFactor = 2;
      supportedFeatures = [ "big-parallel" "kvm" ];
    }
    {
      hostName = "swa.sh";
      systems = [ "x86_64-linux" "aarch64-linux" ];
      maxJobs = 8;
      speedFactor = 3;
      supportedFeatures = [ "big-parallel" "kvm" ];
    }
  ];

  nix.distributedBuilds = true;

  users.users.mbrock = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJD7B4saBw7XXHcNMeO8MVudPSUDWwzje5y0lLQPP7Ub mikael@brockman.se"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  # User environment setup
  environment.etc."npmrc" = {
    text = ''
      prefix=~/.local
      cache=~/.cache/npm
    '';
    user = "mbrock";
  };

  # Session variables
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    EDITOR = "emacs";
  };

  # Mako notification daemon as a systemd user service
  systemd.user.services.mako = {
    description = "Mako notification daemon";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "dbus";
      BusName = "org.freedesktop.Notifications";
      ExecStart = "${pkgs.mako}/bin/mako";
      RestartSec = 5;
      Restart = "always";
    };
  };

  # Create mako config
  environment.etc."xdg/mako/config" = {
    text = ''
      default-timeout=3000
      border-size=3
      border-radius=12
      border-color=#daa520
      background-color=#1a1510
      text-color=#e8d5b7
      font=JetBrains Mono 12
      padding=20
      width=700
      anchor=center
    '';
  };

  # Kitty configuration for all users
  environment.etc."xdg/kitty/kitty.conf" = {
    text = ''
      # Font
      font_family JetBrains Mono
      font_size 18

      # Window appearance
      background_opacity 0.90
      window_padding_width 8

      # Colors - Subtle warm theme
      background #0a0a0a
      foreground #e8e8e8
      selection_background #444444
      selection_foreground #e8e8e8
      cursor #cccccc
      cursor_text_color #0a0a0a

      # Black
      color0 #404040
      color8 #aaaaaa

      # Red
      color1 #cd5c5c
      color9 #ff6347

      # Green
      color2 #9acd32
      color10 #adff2f

      # Yellow
      color3 #d4af37
      color11 #ffd700

      # Blue
      color4 #8ab4f8
      color12 #aecbfa

      # Magenta
      color5 #ba55d3
      color13 #da70d6

      # Cyan
      color6 #5fcbd8
      color14 #87ceeb

      # White
      color7 #dddddd
      color15 #f0f0f0

      # Tab bar
      tab_bar_style powerline
      tab_bar_background #0a0a0a
      active_tab_foreground #0a0a0a
      active_tab_background #cccccc
      inactive_tab_foreground #888888
      inactive_tab_background #2a2a2a

      # Performance
      repaint_delay 10
      input_delay 3
      sync_to_monitor yes
    '';
  };

  system.stateVersion = "25.05"; # never change or delete
}
