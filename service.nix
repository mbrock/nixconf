{ config, pkgs, ... }:

{
  systemd.user.services.nt = {
    Unit = {
      Description = "Node.Town Server";
      After = [
        "network.target"
        "agenix.service"
      ];
      Wants = [ "agenix.service" ];
    };

    Service = {
      Type = "simple";
      WorkingDirectory = "%h/2025/nt";
      # Create data and images directories before starting
      ExecStartPre = [
        "${pkgs.coreutils}/bin/mkdir -p %h/.local/state/nt_data_service"
        "${pkgs.coreutils}/bin/mkdir -p %h/.local/share/nt_images"
      ];
      # Run in foreground mode for systemd, on port 2026
      ExecStart = "${pkgs.swi-prolog}/bin/swipl main.pl --no-fork --port=2026";
      # Send SIGHUP to reload code when service is reloaded
      ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
      Restart = "on-failure";
      RestartSec = "5s";

      # Environment variables including dedicated data directory
      Environment = [
        "HOME=%h"
        "PATH=${pkgs.swi-prolog}/bin:/usr/bin:/bin"
        "NT_DATA_DIR=%h/.local/state/nt_data_service"
        "NT_IMAGES_DIR=%h/.local/share/nt_images"
      ];

      # Load secrets from agenix (using absolute path since systemd doesn't expand variables)
      EnvironmentFile = "/run/user/1000/agenix/nt-api-keys";

      # Send output to journal
      StandardOutput = "journal";
      StandardError = "journal";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
