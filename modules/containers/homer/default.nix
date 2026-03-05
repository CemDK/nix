{ configBase, ... }:
{
  virtualisation.oci-containers.containers.homer = {
    image = "b4bz/homer:latest";
    pull = "newer";
    hostname = "homer";
    networks = [ "traefik_network" ];

    environment = {
      "TZ" = "Europe/Berlin";
    };

    volumes = [
      "${configBase}/homer/data:/www/assets"
    ];

    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.homer.rule" = "Host(`homer.cemdk.net`)";
      "traefik.http.routers.homer.entrypoints" = "websecure";
      "traefik.http.routers.homer.tls" = "true";
      "traefik.http.routers.homer.tls.certresolver" = "letsencrypt";
      "traefik.http.routers.homer.service" = "homer";
      "traefik.http.services.homer.loadbalancer.server.port" = "8080";
    };
  };
}
