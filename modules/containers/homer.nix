{
  image = "b4bz/homer:latest";

  environment = {
    "TZ" = "Europe/Berlin";
  };

  user = "root:root";

  volumes = [
    "/home/cemdk/docker/homer/assets:/www/assets"
  ];

  extraOptions = [
    "--pull=newer"
    "--name=homer"
    "--hostname=homer"
    "--network=traefik_network"
    "--label=traefik.enable=true"
    "--label=traefik.http.routers.homer.rule=Host(`homer.local`)"
    "--label=traefik.http.routers.homer.entrypoints=websecure"
    "--label=traefik.http.routers.homer.tls=true"
    "--label=traefik.http.services.homer.loadbalancer.server.port=8080"
  ];
}
