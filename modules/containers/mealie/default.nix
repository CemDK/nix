{ configBase, ... }:
{
  systemd.tmpfiles.rules = [
    "d ${configBase}/mealie/data 0755 root root -"
  ];

  virtualisation.oci-containers.containers.mealie = {
    image = "ghcr.io/mealie-recipes/mealie:v3.11.0";
    pull = "newer";
    hostname = "mealie";
    networks = [ "traefik_network" ];

    environment = {
      "TZ" = "Europe/Berlin";
      "ALLOW_SIGNUP" = "false";
      "MAX_WORKERS" = "1";
      "WEB_CONCURRENCY" = "1";
      "BASE_URL" = "https://mealie.cemdk.net";
    };

    volumes = [
      "${configBase}/mealie/data:/app/data/"
    ];

    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.mealie.rule" = "Host(`mealie.cemdk.net`)";
      "traefik.http.routers.mealie.entrypoints" = "websecure";
      "traefik.http.routers.mealie.tls.certresolver" = "letsencrypt";
      "traefik.http.services.mealie.loadbalancer.server.port" = "9000";
    };
  };
}
