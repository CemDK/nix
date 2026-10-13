{
  config,
  lib,
  ...
}:
let
  container = "adguardhome";

  homelab = config.homelab;
  shared = config.homelab.containers;
  cfg = config.homelab.containers.${container};

  helpers = import ../helpers.nix { inherit lib; };

  image = "adguard/adguardhome:latest";
  # Web UI. The first-run wizard listens on 3000; pick 3000 for the admin UI
  # there too, so Traefik keeps routing to it after setup.
  port = "3000";
in
{

  # ============================================================================
  # OPTIONS
  # ============================================================================
  options.homelab.containers.${container} = {
    enable = lib.mkEnableOption container;
    url = lib.mkOption {
      type = lib.types.str;
      default = "adguard.${homelab.domain}";
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
      { directory = "${cfg.configDir}/data/work"; }
      { directory = "${cfg.configDir}/data/conf"; }
    ];

    virtualisation.oci-containers.containers.${container} = {
      inherit image;
      pull = "newer";
      hostname = container;
      networks = [ shared.networks.traefik ];
      environment = shared.environment;

      # Rootful podman DNATs published ports, so AdGuard sees the clients'
      # real IPs (needed for per-client rules and schedules).
      ports = [
        "53:53/tcp"
        "53:53/udp"
      ];

      volumes = [
        "${cfg.configDir}/data/work:/opt/adguardhome/work"
        "${cfg.configDir}/data/conf:/opt/adguardhome/conf"
      ];

      labels = helpers.mkTraefikLabels {
        name = container;
        url = cfg.url;
        inherit port;
      };
    };

    networking.firewall = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 ];
    };
  };
}
