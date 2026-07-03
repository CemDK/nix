{
  config,
  pkgs,
  lib,
  ...
}:
let
  containers = config.homelab.containers;
  systemctl = lib.getExe' pkgs.systemd "systemctl";

  # Containers with mutable databases or state, stopped during backup
  statefulContainers = [
    "audiobookshelf"
    "calibre-web"
    "mealie"
    "navidrome"
    "radarr"
    "sabnzbd"
    "seerr"
    "sonarr"
  ];

  # Config-only containers, safe to back up while running
  configOnlyContainers = [
    "homer"
    "traefik"
  ];

  servicesToStop = map (name: "podman-${name}") statefulContainers;

  stopAll = lib.concatMapStrings (s: "${systemctl} stop ${s}.service || true\n") servicesToStop;
  startAll = lib.concatMapStrings (s: "${systemctl} start ${s}.service || true\n") servicesToStop;
in
{
  sops.secrets."restic/password" = { };

  services.restic.backups.containers = {
    initialize = true;

    # Paths derive from each container's configDir option so they can't
    # drift from where the containers actually mount their volumes.
    paths =
      map (name: "${containers.${name}.configDir}/data") (statefulContainers ++ configOnlyContainers)
      ++ [ "${containers.arr-stack.configDir}/wireguard/data" ];

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
