{ config, ... }:
let
  cfg = config.homelab.containers;
  inherit (config.homelab) domain;
in
{
  homelab.containers.requiredDirs = [
    { directory = "${cfg.configPath}/calibre-web/data/config"; }
    {
      directory = "${cfg.storagePath}/media/calibre";
      owner = "root";
      group = "root";
    }
  ];

  virtualisation.oci-containers.containers.calibre-web = {
    image = "lscr.io/linuxserver/calibre-web:latest";
    pull = "newer";
    hostname = "calibre-web";
    networks = [ cfg.networks.traefik ];

    environment = cfg.commonEnv;

    volumes = [
      "${cfg.configPath}/calibre-web/data/config:/config"
      "${cfg.storagePath}/media/calibre:/books"
    ];

    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.calibre.rule" = "Host(`calibre.${domain}`)";
      "traefik.http.routers.calibre.entrypoints" = "websecure";
      "traefik.http.routers.calibre.tls.certresolver" = "letsencrypt";
      "traefik.http.services.calibre.loadbalancer.server.port" = "8083";
    };
  };
}
