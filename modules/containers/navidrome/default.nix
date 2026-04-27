{
  config,
  lib,
  ...
}:
let
  container = "navidrome";

  homelab = config.homelab;
  shared = config.homelab.containers;
  cfg = config.homelab.containers.${container};

  helpers = import ../helpers.nix { inherit lib; };

  image = "deluan/navidrome:latest";
  port = "4533";
in
{

  # ============================================================================
  # OPTIONS
  # ============================================================================
  options.homelab.containers.${container} = {
    enable = lib.mkEnableOption {
      description = "Enable ${container}";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "music.${homelab.domain}";
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "${shared.configPath}/${container}";
    };
  };

  # ============================================================================
  # CONFIG
  # ============================================================================
  config = lib.mkIf cfg.enable {
    homelab.containers.networks.consumers = [ container ];
    homelab.containers.requiredDirs = [
      { directory = "${cfg.configDir}/data"; }
      { directory = "${shared.storagePath}/media/music"; }
    ];

    virtualisation.oci-containers.containers.${container} = {
      inherit image;
      pull = "newer";
      hostname = container;
      networks = [ shared.networks.traefik ];

      environment = shared.commonEnv // {
        "ND_SCANSCHEDULE" = "24h";
        "ND_LOGLEVEL" = "info";
        "ND_SESSIONTIMEOUT" = "24h";
        "ND_BASEURL" = "https://${cfg.url}";
      };

      volumes = [
        "${cfg.configDir}/data:/data"
        "${shared.storagePath}/media/music:/music:ro"
      ];

      labels = helpers.mkTraefikLabels {
        name = container;
        url = cfg.url;
        inherit port;
      };
    };
  };
}
