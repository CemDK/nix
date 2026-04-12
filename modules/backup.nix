{
  config,
  pkgs,
  ...
}:
let
  containerData = config.homelab.containers.configPath;
in
{
  # TODO: Add to secrets/global.yaml before enabling:
  #   restic/password: <your-secure-password>
  sops.secrets."restic/password" = { };

  services.restic.backups.containers = {
    initialize = true;

    paths = [
      "${containerData}/navidrome/data"
      "${containerData}/audiobookshelf/data"
    ];

    exclude = [
      # Caches — regenerated automatically
      "*/cache/*"
      # Logs — not worth backing up
      "*/logs/*"
      # Migrations — shipped with the app
      "*/migrations/*"
      # SQLite temp files — regenerated on DB open
      "*.db-shm"
      "*.db-wal"
    ];

    repository = "/mnt/backups/containers/restic";

    passwordFile = config.sops.secrets."restic/password".path;

    timerConfig = {
      OnCalendar = "daily";
      Persistent = true; # Run if machine was off at scheduled time
    };

    # Stop containers before backup to prevent SQLite corruption
    backupPrepareCommand = ''
      ${pkgs.lib.getExe' pkgs.systemd "systemctl"} stop podman-navidrome.service || true
      ${pkgs.lib.getExe' pkgs.systemd "systemctl"} stop podman-audiobookshelf.service || true
      sleep 2
    '';

    backupCleanupCommand = ''
      ${pkgs.lib.getExe' pkgs.systemd "systemctl"} start podman-navidrome.service || true
      ${pkgs.lib.getExe' pkgs.systemd "systemctl"} start podman-audiobookshelf.service || true
    '';

    pruneOpts = [
      "--keep-daily 30"
      "--keep-weekly 52"
    ];
  };
}
