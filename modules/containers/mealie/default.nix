{ config, user, ... }:
let
  cfg = config.homelab.containers;
  domain = config.homelab.domain;
in
{
  systemd.tmpfiles.rules = [
    "d ${cfg.configPath}/mealie/data 0755 ${user} users -"
  ];

  virtualisation.oci-containers.containers.mealie = {
    image = "ghcr.io/mealie-recipes/mealie:v3.11.0";
    pull = "newer";
    hostname = "mealie";
    networks = [ cfg.networks.traefik ];

    environment = cfg.commonEnv // {
      "ALLOW_SIGNUP" = "false";
      "MAX_WORKERS" = "1";
      "WEB_CONCURRENCY" = "1";
      "BASE_URL" = "https://mealie.${domain}";
    };

    volumes = [
      "${cfg.configPath}/mealie/data:/app/data/"
    ];

    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.mealie.rule" = "Host(`mealie.${domain}`)";
      "traefik.http.routers.mealie.entrypoints" = "websecure";
      "traefik.http.routers.mealie.tls.certresolver" = "letsencrypt";
      "traefik.http.services.mealie.loadbalancer.server.port" = "9000";
    };
  };
}
