{ config, ... }:
let
  cfg = config.homelab.containers;
  domain = config.homelab.domain;
in
{
  homelab.containers.requiredDirs = [
    { directory = "${cfg.configPath}/navidrome/data"; }
    {
      directory = "${cfg.storagePath}/media/music";
      owner = "root";
      group = "root";
    }
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
