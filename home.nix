{ config, pkgs, ... }:

{
  imports = [
    #    ./service.nix
  ];

  home.username = "mbrock";
  home.homeDirectory = "/home/mbrock";
  home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];

  home.packages = [
    pkgs.font-manager
    pkgs.age
    pkgs.ragenix
  ];

  home.file.".npmrc".text = ''
    prefix=~/.local
    cache=~/.cache/npm
  '';

  home.sessionVariables.EDITOR = "emacs";

  programs.bash = {
    enable = true;
    shellAliases = {
      ls = "ls --color=auto";
      grep = "grep --color=auto";
    };
  };

  programs.home-manager.enable = true;
  programs.starship.enable = true;
  programs.starship.enableBashIntegration = true;

  programs.direnv.enable = true;

  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrains Mono";
      size = 18;
    };
    settings = {
      # Window appearance
      background_opacity = "0.90";
      window_padding_width = 8;

      # Colors - Subtle warm theme
      background = "#0a0a0a";
      foreground = "#e8e8e8";
      selection_background = "#444444";
      selection_foreground = "#e8e8e8";
      cursor = "#cccccc";
      cursor_text_color = "#0a0a0a";

      # Black
      color0 = "#1a1a1a";
      color8 = "#555555";

      # Red
      color1 = "#cd5c5c";
      color9 = "#ff6347";

      # Green
      color2 = "#9acd32";
      color10 = "#adff2f";

      # Yellow
      color3 = "#d4af37";
      color11 = "#ffd700";

      # Blue
      color4 = "#6495ed";
      color12 = "#87ceeb";

      # Magenta
      color5 = "#ba55d3";
      color13 = "#da70d6";

      # Cyan
      color6 = "#5fcbd8";
      color14 = "#87ceeb";

      # White
      color7 = "#cccccc";
      color15 = "#e8e8e8";

      # Tab bar
      tab_bar_style = "powerline";
      tab_bar_background = "#0a0a0a";
      active_tab_foreground = "#0a0a0a";
      active_tab_background = "#cccccc";
      inactive_tab_foreground = "#888888";
      inactive_tab_background = "#2a2a2a";

      # Performance
      repaint_delay = 10;
      input_delay = 3;
      sync_to_monitor = true;
    };
  };

  services.podman.enable = true;

  services.mako = {
    enable = true;
    settings = {
      default-timeout = 3000;
      border-size = 3;
      border-radius = 12;
      border-color = "#daa520";
      background-color = "#1a1510";
      text-color = "#e8d5b7";
      font = "JetBrains Mono 12";
      padding = "20";
      width = 700;
      anchor = "center";
    };
  };

  fonts.fontconfig.enable = true;

  # Age secrets configuration
  age.secrets.nt-api-keys = {
    file = ./secrets/nt-api-keys.age;
  };

  # Configure agenix to use SSH keys
  age.identityPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];

  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.
}
