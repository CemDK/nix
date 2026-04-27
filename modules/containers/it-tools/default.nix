{
  config,
  lib,
  ...
}:
let
  container = "it-tools";

  homelab = config.homelab;
  shared = config.homelab.containers;
  cfg = config.homelab.containers.${container};

  helpers = import ../helpers.nix { inherit lib; };

  image = "ghcr.io/corentinth/it-tools:latest";
  port = "80";
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
  };

  # ============================================================================
  # CONFIG
  # ============================================================================
  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.${container} = {
      inherit image;
      pull = "newer";
      hostname = container;
      networks = [ shared.networks.traefik ];
      environment = shared.commonEnv;

      labels = helpers.mkTraefikLabels {
        name = container;
        url = cfg.url;
        inherit port;
      };
    };
  };
}
