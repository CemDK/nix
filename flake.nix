{
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixvim, nix-darwin, home-manager, nixpkgs }:
    let
      mkDarwinConfig = { system, host, user, home }:
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit host user home; };
          modules = [
            ({ pkgs, config, ... }:
              import ./darwin-configuration.nix {
                inherit pkgs self system user home;
              })

            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit user home; };
                users.${user} = ({ pkgs, ... }:
                  import ./users/${user}/home.nix { inherit pkgs user home; });
              };
            }

            nixvim.nixDarwinModules.nixvim
            { programs = { nixvim = import ./modules/nixvim; }; }
          ];
        };

    in {
      darwinConfigurations = {
        "CemDK-MBP" = mkDarwinConfig {
          system = "x86_64-darwin";
          host = "CemDK-MBP";
          user = "cem";
          home = "/Users/cem";
        };

        "default" = mkDarwinConfig {
          system = "aarch64-darwin";
          host = "default";
          user = "kaba03";
          home = "/Users/kaba03";
        };
      };
    };
}
