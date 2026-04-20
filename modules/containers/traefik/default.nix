{
  config,
  self,
  ...
}:
let
  cfg = config.homelab.containers;
  inherit (config.homelab) domain;
in
{
  # Define secrets on the host system
  # Secrets files will be in /run/secrets/traefik/...
  sops.secrets = {
    "traefik/dashboard-users" = {
      sopsFile = "${self}/secrets/homelab/secrets.yaml";
    };
    "traefik/env" = {
      sopsFile = "${self}/secrets/homelab/secrets.yaml";
    };
  };

  homelab.containers.requiredDirs = [
    { directory = "${cfg.configPath}/traefik/data/acme"; }
  ];

  virtualisation.oci-containers.containers.traefik = {
    image = "traefik:v3.3";
    pull = "newer";
    hostname = "traefik";
    networks = [
      cfg.networks.traefik
      cfg.networks.vpnMedia
    ];

    environment = cfg.commonEnv;

    # This makes ENV vars in the container from the file on the host /run/secrets/traefik/env
    environmentFiles = [
      config.sops.secrets."traefik/env".path
    ];

    ports = [
      "80:80"
      "443:443"
    ];

    volumes = [
      "/run/podman/podman.sock:/var/run/docker.sock:ro"
      "${cfg.configPath}/traefik/data/traefik.yml:/etc/traefik/traefik.yml:ro"
      "${cfg.configPath}/traefik/data/dynamic/middlewares.yml:/etc/traefik/dynamic/middlewares.yml:ro"
      "${cfg.configPath}/traefik/data/acme:/etc/traefik/acme"
      "${config.sops.secrets."traefik/dashboard-users".path}:/etc/traefik/dynamic/dashboard-users:ro"
    ];

    extraOptions = [ "--security-opt=no-new-privileges" ];

    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.dashboard.rule" = "Host(`traefik.${domain}`)";
      "traefik.http.routers.dashboard.service" = "api@internal";
      "traefik.http.routers.dashboard.middlewares" = "dashboard-auth@file,vpn-whitelist@file";
      "traefik.http.routers.dashboard.tls" = "true";
      "traefik.http.routers.dashboard.tls.certresolver" = "letsencrypt";
    };
  };
}
