{ config, ... }:
let
  cfg = config.homelab.containers;
  inherit (config.homelab) domain;
in
{
  homelab.containers.requiredDirs = [
    {
      directory = "${cfg.storagePath}/media/audiobooks/books";
      owner = "root";
      group = "root";
    }
    {
      directory = "${cfg.storagePath}/media/podcasts";
      owner = "root";
      group = "root";
    }
    { directory = "${cfg.configPath}/audiobookshelf/data/config"; }
    { directory = "${cfg.configPath}/audiobookshelf/data/metadata"; }
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
