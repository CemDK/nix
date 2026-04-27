{
  config,
  lib,
  self,
  ...
}:
let
  container = "traefik";

  homelab = config.homelab;
  shared = config.homelab.containers;
  cfg = config.homelab.containers.${container};

  image = "traefik:v3.3";
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
    sops.secrets = {
      "traefik/dashboard-users" = {
        sopsFile = "${self}/secrets/homelab/secrets.yaml";
      };
      "traefik/env" = {
        sopsFile = "${self}/secrets/homelab/secrets.yaml";
      };
    };

    homelab.containers.requiredDirs = [
      { directory = "${cfg.configDir}/data/acme"; }
    ];

    virtualisation.oci-containers.containers.${container} = {
      inherit image;
      pull = "newer";
      hostname = container;
      networks = [
        shared.networks.traefik
        shared.networks.vpnMedia
      ];

      environment = shared.commonEnv;

      environmentFiles = [
        config.sops.secrets."traefik/env".path
      ];

      ports = [
        "80:80"
        "443:443"
      ];

      volumes = [
        "/run/podman/podman.sock:/var/run/docker.sock:ro"
        "${cfg.configDir}/data/traefik.yml:/etc/traefik/traefik.yml:ro"
        "${cfg.configDir}/data/dynamic/middlewares.yml:/etc/traefik/dynamic/middlewares.yml:ro"
        "${cfg.configDir}/data/acme:/etc/traefik/acme"
        "${config.sops.secrets."traefik/dashboard-users".path}:/etc/traefik/dynamic/dashboard-users:ro"
      ];

      extraOptions = [ "--security-opt=no-new-privileges" ];

      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.dashboard.rule" = "Host(`${cfg.url}`)";
        "traefik.http.routers.dashboard.service" = "api@internal";
        "traefik.http.routers.dashboard.middlewares" = "dashboard-auth@file,vpn-whitelist@file";
        "traefik.http.routers.dashboard.tls" = "true";
        "traefik.http.routers.dashboard.tls.certresolver" = "letsencrypt";
      };
    };
  };
}
