{ config, user, ... }:
let
  cfg = config.homelab.containers;
  domain = config.homelab.domain;
in
{
  systemd.tmpfiles.rules = [
    "d ${cfg.configPath}/navidrome/data 0755 ${user} users -"
    "d ${cfg.storagePath}/media/music 0755 root root -"
  ];

  virtualisation.oci-containers.containers.navidrome = {
    image = "deluan/navidrome:latest";
    pull = "newer";
    hostname = "navidrome";
    networks = [ cfg.networks.traefik ];

    environment = cfg.commonEnv // {
      "ND_SCANSCHEDULE" = "24h";
      "ND_LOGLEVEL" = "info";
      "ND_SESSIONTIMEOUT" = "24h";
      "ND_BASEURL" = "https://music.${domain}";
    };

    volumes = [
      "${cfg.configPath}/navidrome/data:/data"
      "${cfg.storagePath}/media/music:/music:ro"
    ];

    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.navidrome.rule" = "Host(`music.${domain}`)";
      "traefik.http.routers.navidrome.entrypoints" = "websecure";
      "traefik.http.routers.navidrome.tls.certresolver" = "letsencrypt";
      "traefik.http.services.navidrome.loadbalancer.server.port" = "4533";
    };
  };
}
