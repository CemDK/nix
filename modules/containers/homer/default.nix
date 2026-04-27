{
  config,
  lib,
  ...
}:
let
  container = "homer";

  homelab = config.homelab;
  shared = config.homelab.containers;
  cfg = config.homelab.containers.${container};

  helpers = import ../helpers.nix { inherit lib; };

  image = "b4bz/homer:latest";
  port = "8080";
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
      environment = shared.commonEnv;

      volumes = [
        "${cfg.configDir}/data:/www/assets"
      ];

      labels = helpers.mkTraefikLabels {
        name = container;
        url = cfg.url;
        inherit port;
      };
    };
  };
}
