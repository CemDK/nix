{ configBase, ... }:
{
  config,
  self,
  ...
}:
{
  # Define secrets on the host system
  # Secrets files will be in /run/secrets/traefik/...
  sops.secrets = {
    "traefik/dashboard-users" = {
      sopsFile = "${self}/secrets/homelab/secrets.yaml";
    };
    "traefik/cloudflare-env" = {
      sopsFile = "${self}/secrets/homelab/secrets.yaml";
    };
  };

  systemd.tmpfiles.rules = [
    "d ${configBase}/traefik/data/acme 0755 root root -"
  ];

  virtualisation.oci-containers.containers.traefik = {
    image = "traefik:v3.3";
    pull = "newer";
    hostname = "traefik";
    networks = [ "traefik_network" ];

    environment = {
      "TZ" = "Europe/Berlin";
    };

    # This makes ENV vars in the container from the file on the host /run/secrets/traefik/cloudflare-env
    environmentFiles = [
      config.sops.secrets."traefik/cloudflare-env".path
    ];

    ports = [
      "80:80"
      "443:443"
    ];

    volumes = [
      "/run/podman/podman.sock:/var/run/docker.sock:ro"
      "${configBase}/traefik/data/traefik.yml:/etc/traefik/traefik.yml:ro"
      "${configBase}/traefik/data/dynamic/middlewares.yml:/etc/traefik/dynamic/middlewares.yml:ro"
      "${configBase}/traefik/data/acme:/etc/traefik/acme"
      "${config.sops.secrets."traefik/dashboard-users".path}:/etc/traefik/dynamic/dashboard-users:ro"
    ];

    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.dashboard.rule" = "Host(`traefik.cemdk.net`)";
      "traefik.http.routers.dashboard.service" = "api@internal";
      "traefik.http.routers.dashboard.middlewares" = "dashboard-auth@file,vpn-whitelist@file";
      "traefik.http.routers.dashboard.tls" = "true";
      "traefik.http.routers.dashboard.tls.certresolver" = "letsencrypt";
    };
  };
}
