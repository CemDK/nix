{
  config,
  lib,
  ...
}:
let
  container = "mealie";

  homelab = config.homelab;
  shared = config.homelab.containers;
  cfg = config.homelab.containers.${container};

  helpers = import ../helpers.nix { inherit lib; };

  image = "ghcr.io/mealie-recipes/mealie:v3.11.0";
  port = "9000";
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
      default = "${container}.${homelab.domain}";
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
    ];

    virtualisation.oci-containers.containers.${container} = {
      inherit image;
      pull = "newer";
      hostname = container;
      networks = [ shared.networks.traefik ];

      environment = shared.commonEnv // {
        "ALLOW_SIGNUP" = "false";
        "MAX_WORKERS" = "1";
        "WEB_CONCURRENCY" = "1";
        "BASE_URL" = "https://${cfg.url}";
      };

      volumes = [
        "${cfg.configDir}/data:/app/data/"
      ];

      labels = helpers.mkTraefikLabels {
        name = container;
        url = cfg.url;
        inherit port;
      };
    };
  };
}
