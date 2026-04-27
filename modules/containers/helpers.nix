{ lib }:
{
  mkTraefikLabels =
    {
      name,
      url,
      port,
      middlewares ? [],
    }:
    {
      "traefik.enable" = "true";
      "traefik.http.routers.${name}.rule" = "Host(`${url}`)";
      "traefik.http.routers.${name}.entrypoints" = "websecure";
      "traefik.http.routers.${name}.tls.certresolver" = "letsencrypt";
      "traefik.http.routers.${name}.service" = name;
      "traefik.http.services.${name}.loadbalancer.server.port" = port;
    }
    // lib.optionalAttrs (middlewares != [ ]) {
      "traefik.http.routers.${name}.middlewares" = lib.concatStringsSep "," middlewares;
    };
}
