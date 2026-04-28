{
  config,
  lib,
  ...
}:
let
  container = "audiobookshelf";

  homelab = config.homelab;
  shared = config.homelab.containers;
  cfg = config.homelab.containers.${container};

  helpers = import ../helpers.nix { inherit lib; };

  image = "ghcr.io/advplyr/audiobookshelf:latest";
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
      { directory = "${shared.storagePath}/media/audiobooks/books"; }
      { directory = "${shared.storagePath}/media/podcasts"; }
      { directory = "${cfg.configDir}/data/config"; }
      { directory = "${cfg.configDir}/data/metadata"; }
    ];

    virtualisation.oci-containers.containers.${container} = {
      inherit image;
      pull = "newer";
      hostname = container;
      networks = [ shared.networks.traefik ];
      environment = shared.environment;

      volumes = [
        "${shared.storagePath}/media/audiobooks/books:/audiobooks"
        "${shared.storagePath}/media/podcasts:/podcasts"
        "${cfg.configDir}/data/config:/config"
        "${cfg.configDir}/data/metadata:/metadata"
      ];

      labels = helpers.mkTraefikLabels {
        name = container;
        url = cfg.url;
        inherit port;
      };
    };
  };
}
