{ configBase, storagePath, ... }:
{
  # Make sure required directories exist before container starts
  systemd.tmpfiles.rules = [
    "d ${storagePath}/media/audiobooks/books 0755 root root -"
    "d ${storagePath}/media/podcasts 0755 root root -"
    "d ${configBase}/audiobookshelf/data/config 0755 root root -"
    "d ${configBase}/audiobookshelf/data/metadata 0755 root root -"
  ];

  virtualisation.oci-containers.containers.audiobookshelf = {
    image = "ghcr.io/advplyr/audiobookshelf:latest";
    pull = "newer";
    hostname = "audiobookshelf";
    networks = [ "traefik_network" ];

    environment = {
      "TZ" = "Europe/Berlin";
    };

    volumes = [
      "${storagePath}/media/audiobooks/books:/audiobooks"
      "${storagePath}/media/podcasts:/podcasts"
      "${configBase}/audiobookshelf/data/config:/config"
      "${configBase}/audiobookshelf/data/metadata:/metadata"
    ];

    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.abs.rule" = "Host(`audiobookshelf.cemdk.net`)";
      "traefik.http.routers.abs.entrypoints" = "websecure";
      "traefik.http.routers.abs.tls.certresolver" = "letsencrypt";
      "traefik.http.services.abs.loadbalancer.server.port" = "80";
    };
  };
}
