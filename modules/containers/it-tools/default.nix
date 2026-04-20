{ config, ... }:
let
  cfg = config.homelab.containers;
  inherit (config.homelab) domain;
in
{
  virtualisation.oci-containers.containers.it-tools = {
    image = "ghcr.io/corentinth/it-tools:latest";
    pull = "newer";
    hostname = "it-tools";
    networks = [ cfg.networks.traefik ];

    environment = cfg.commonEnv;

    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.it-tools.rule" = "Host(`it-tools.${domain}`)";
      "traefik.http.routers.it-tools.entrypoints" = "websecure";
      "traefik.http.routers.it-tools.tls.certresolver" = "letsencrypt";
      "traefik.http.services.it-tools.loadbalancer.server.port" = "80";
    };
  };
}
