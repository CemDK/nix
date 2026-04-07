{ config, user, ... }:
let
  cfg = config.homelab.containers;
  domain = config.homelab.domain;
in
{
  systemd.tmpfiles.rules = [
    "d ${cfg.configPath}/calibre-web/data/config 0755 ${user} users -"
    "d ${cfg.storagePath}/media/calibre 0755 root root -"
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
