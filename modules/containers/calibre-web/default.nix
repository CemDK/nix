{ configBase, storagePath, ... }:
{
  systemd.tmpfiles.rules = [
    "d ${configBase}/calibre-web/data/config 0755 root root -"
    "d ${storagePath}/media/calibre 0755 root root -"
  ];

  virtualisation.oci-containers.containers.calibre-web = {
    image = "lscr.io/linuxserver/calibre-web:latest";
    pull = "newer";
    hostname = "calibre-web";
    networks = [ "traefik_network" ];

    environment = {
      "TZ" = "Europe/Berlin";
    };

    volumes = [
      "${configBase}/calibre-web/data/config:/config"
      "${storagePath}/media/calibre:/books"
    ];

    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.calibre.rule" = "Host(`calibre.cemdk.net`)";
      "traefik.http.routers.calibre.entrypoints" = "websecure";
      "traefik.http.routers.calibre.tls.certresolver" = "letsencrypt";
      "traefik.http.services.calibre.loadbalancer.server.port" = "8083";
    };
  };
}
