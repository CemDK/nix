{ config, user, ... }:
let
  cfg = config.homelab.containers;
  domain = config.homelab.domain;
in
{
  systemd.tmpfiles.rules = [
    "d ${cfg.storagePath}/media/audiobooks/books 0755 root root -"
    "d ${cfg.storagePath}/media/podcasts 0755 root root -"
    "d ${cfg.configPath}/audiobookshelf/data/config 0755 ${user} users -"
    "d ${cfg.configPath}/audiobookshelf/data/metadata 0755 ${user} users -"
  ];

  virtualisation.oci-containers.containers.audiobookshelf = {
    image = "ghcr.io/advplyr/audiobookshelf:latest";
    pull = "newer";
    hostname = "audiobookshelf";
    networks = [ cfg.networks.traefik ];

    environment = cfg.commonEnv;

    volumes = [
      "${cfg.storagePath}/media/audiobooks/books:/audiobooks"
      "${cfg.storagePath}/media/podcasts:/podcasts"
      "${cfg.configPath}/audiobookshelf/data/config:/config"
      "${cfg.configPath}/audiobookshelf/data/metadata:/metadata"
    ];

    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.abs.rule" = "Host(`audiobookshelf.${domain}`)";
      "traefik.http.routers.abs.entrypoints" = "websecure";
      "traefik.http.routers.abs.tls.certresolver" = "letsencrypt";
      "traefik.http.services.abs.loadbalancer.server.port" = "80";
    };
  };
}
