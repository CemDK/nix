{
  config,
  pkgs,
  lib,
  ...
}:
let
  containerData = config.homelab.containers.configPath;
  systemctl = lib.getExe' pkgs.systemd "systemctl";

  # Services to stop before backup (have mutable databases or state)
  servicesToStop = [
    "podman-navidrome"
    "podman-audiobookshelf"
    "podman-sonarr"
    "podman-radarr"
    "podman-sabnzbd"
    "podman-seerr"
    "podman-mealie"
    "podman-calibre-web"
  ];

  stopAll = lib.concatMapStrings (s: "${systemctl} stop ${s}.service || true\n") servicesToStop;
  startAll = lib.concatMapStrings (s: "${systemctl} start ${s}.service || true\n") servicesToStop;
in
{
  sops.secrets."restic/password" = { };

  services.restic.backups.containers = {
    initialize = true;

    paths = [
      "${containerData}/navidrome/data"
      "${containerData}/audiobookshelf/data"
      "${containerData}/arr/sonarr/data"
      "${containerData}/arr/radarr/data"
      "${containerData}/arr/sabnzbd/data"
      "${containerData}/arr/seerr/data"
      "${containerData}/arr/wireguard/data"
      "${containerData}/traefik/data"
      "${containerData}/mealie/data"
      "${containerData}/calibre-web/data"
      "${containerData}/homer/data"
    ];

    exclude = [
      "*/cache/*"
      "*/logs/*"
      "*/migrations/*"
      "*.db-shm"
      "*.db-wal"
    ];

    repository = "/mnt/backups/containers/restic";

    passwordFile = config.sops.secrets."restic/password".path;

    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };

    backupPrepareCommand = ''
      ${stopAll}
      sleep 2
    '';

    backupCleanupCommand = startAll;

    pruneOpts = [
      "--keep-daily 30"
      "--keep-weekly 52"
    ];
  };
}
