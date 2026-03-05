{ ... }:
{
  virtualisation.oci-containers.containers.it-tools = {
    image = "ghcr.io/corentinth/it-tools:latest";
    pull = "newer";
    hostname = "it-tools";
    networks = [ "traefik_network" ];

    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.it-tools.rule" = "Host(`it-tools.cemdk.net`)";
      "traefik.http.routers.it-tools.entrypoints" = "websecure";
      "traefik.http.routers.it-tools.tls.certresolver" = "letsencrypt";
      "traefik.http.services.it-tools.loadbalancer.server.port" = "80";
    };
  };
}
