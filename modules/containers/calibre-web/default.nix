{
  config,
  lib,
  ...
}:
let
  container = "calibre-web";

  homelab = config.homelab;
  shared = config.homelab.containers;
  cfg = config.homelab.containers.${container};

  helpers = import ../helpers.nix { inherit lib; };

  image = "lscr.io/linuxserver/calibre-web:latest";
  port = "8083";
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
      default = "calibre.${homelab.domain}";
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
      { directory = "${cfg.configDir}/data/config"; }
      { directory = "${shared.storagePath}/media/calibre"; }
    ];

    virtualisation.oci-containers.containers.${container} = {
      inherit image;
      pull = "newer";
      hostname = container;
      networks = [ shared.networks.traefik ];
      environment = shared.environment;

      volumes = [
        "${cfg.configDir}/data/config:/config"
        "${shared.storagePath}/media/calibre:/books"
      ];

      labels = helpers.mkTraefikLabels {
        name = "calibre";
        url = cfg.url;
        inherit port;
      };
    };
  };
}
