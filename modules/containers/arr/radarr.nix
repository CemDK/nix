{
  config,
  lib,
  ...
}:
let
  stack = "arr-stack";
  container = "radarr";

  homelab = config.homelab;
  shared = config.homelab.containers;
  cfg = config.homelab.containers.${container};
in
{

  # ============================================================================
  # OPTIONS
  # ============================================================================
  options.homelab.containers.${container} = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable ${container} (requires ${stack} stack).";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "${container}.${homelab.domain}";
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "${shared.configPath}/${stack}/${container}";
    };
  };

  # ============================================================================
  # CONFIG
  # ============================================================================
  config = lib.mkIf (shared.${stack}.enable && cfg.enable) {
    homelab.containers.${stack}.services.${container}.port = "7878";

    homelab.containers.requiredDirs = [
      { directory = "${cfg.configDir}/data/config"; }
    ];

    virtualisation.oci-containers.containers.${container} = {
      image = "lscr.io/linuxserver/radarr:latest";
      pull = "newer";
      environment = shared.environment;

      volumes = [
        "${cfg.configDir}/data/config:/config"
        "${shared.storagePath}:/data"
      ];
    }
    // shared.${stack}.wireguard.containerConfig;
  };
}
