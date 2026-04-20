{ config, ... }:
let
  cfg = config.homelab.containers;
  inherit (config.homelab) domain;
in
{
  homelab.containers.requiredDirs = [
    { directory = "${cfg.configPath}/homer/data"; }
  ];

  virtualisation.oci-containers.containers.homer = {
    image = "b4bz/homer:latest";
    pull = "newer";
    hostname = "homer";
    networks = [ cfg.networks.traefik ];

    environment = cfg.commonEnv;

    volumes = [
      "${cfg.configPath}/homer/data:/www/assets"
    ];

    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.homer.rule" = "Host(`homer.${domain}`)";
      "traefik.http.routers.homer.entrypoints" = "websecure";
      "traefik.http.routers.homer.tls" = "true";
      "traefik.http.routers.homer.tls.certresolver" = "letsencrypt";
      "traefik.http.routers.homer.service" = "homer";
      "traefik.http.services.homer.loadbalancer.server.port" = "8080";
    };
  };
}
