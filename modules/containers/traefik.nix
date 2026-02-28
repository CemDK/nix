{ config, pkgs, ... }:
let
  traefikStaticConfig = ./traefik/traefik.yml;
in
{
  virtualisation.oci-containers.containers.traefik = {
    image = "traefik:v3.3";

    environment = {
      "TZ" = "Europe/Berlin";
    };

    ports = [
      "80:80"
      "443:443"
      "8080:8080" # Dashboard
    ];

    volumes = [
      "/run/podman/podman.sock:/var/run/docker.sock:ro"
      "${traefikStaticConfig}:/etc/traefik/traefik.yml:ro"
      "${traefikStaticConfig}:/etc/traefik/dynamic/middlewares.yml:ro"
    ];

    extraOptions = [
      "--pull=newer"
      "--name=traefik"
      "--hostname=traefik"
      "--network=traefik_network"
    ];
  };
}
