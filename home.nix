{ config, pkgs, ... }:

{
  home.username = "mbrock";
  home.homeDirectory = "/home/mbrock";
  home.sessionPath = ["${config.home.homeDirectory}/.local/bin"];

  home.packages = [
    pkgs.ghostty
    pkgs.libnotify
  ];

  home.file.".npmrc".text = ''
    prefix=~/.local
    cache=~/.cache/npm
  '';

  home.sessionVariables.EDITOR = "emacs";

  programs.bash.enable = true;
  programs.home-manager.enable = true;
  programs.starship.enable = true;
  programs.starship.enableBashIntegration = true;

  programs.direnv.enable = true;

  services.podman.enable = true;
  
  services.mako = {
    enable = true;
    settings = {
      default-timeout = 3000;
      border-size = 6;
      border-radius = 8;
      border-color = "#335577";
      background-color = "#000000";
      text-color = "#FFFFFF";
      font = "input mono compressed 18";
      padding = "20";
      width = 700;
      anchor = "center";
    };
  };

  fonts.fontconfig.enable = true;

  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.
}
