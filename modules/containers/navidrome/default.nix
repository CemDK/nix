{ configBase, storagePath, ... }:
{
  systemd.tmpfiles.rules = [
    "d ${configBase}/navidrome/data 0755 root root -"
    "d ${storagePath}/media/music 0755 root root -"
  ];

  virtualisation.oci-containers.containers.navidrome = {
    image = "deluan/navidrome:latest";
    pull = "newer";
    hostname = "navidrome";
    networks = [ "traefik_network" ];

    environment = {
      "TZ" = "Europe/Berlin";
      "ND_SCANSCHEDULE" = "24h";
      "ND_LOGLEVEL" = "info";
      "ND_SESSIONTIMEOUT" = "24h";
      "ND_BASEURL" = "https://music.cemdk.net";
    };

    volumes = [
      "${configBase}/navidrome/data:/data"
      "${storagePath}/media/music:/music:ro"
    ];

    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.navidrome.rule" = "Host(`music.cemdk.net`)";
      "traefik.http.routers.navidrome.entrypoints" = "websecure";
      "traefik.http.routers.navidrome.tls.certresolver" = "letsencrypt";
      "traefik.http.services.navidrome.loadbalancer.server.port" = "4533";
    };
  };
}
