{
  config,
  lib,
  ...
}:
let
  stack = "arr-stack";
  container = "sabnzbd";

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
      default = "nzb.${homelab.domain}";
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
    homelab.containers.${stack}.services.${container}.port = "8080";

    homelab.containers.requiredDirs = [
      { directory = "${cfg.configDir}/data/config"; }
    ];

    virtualisation.oci-containers.containers.${container} = {
      image = "lscr.io/linuxserver/sabnzbd:latest";
      pull = "newer";
      environment = shared.commonEnv;

      volumes = [
        "${cfg.configDir}/data/config:/config"
        "${shared.storagePath}:/data"
      ];
    }
    // shared.${stack}.wireguard.containerConfig;
  };
}
