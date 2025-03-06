{
  description = "Multi-platform system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, ... }:
    let
      #############################################################
      # Nix-Darwin configuration
      #############################################################
      mkDarwinConfig = { system, user, host, userHost, home }:
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit host user home inputs; };
          modules = [
            ({ pkgs, config, ... }:
              import ./modules/darwin/system-configuration.nix {
                inherit pkgs self system user home;
              })
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit user home inputs; };
                users.${user} = ({ pkgs, ... }:
                  import ./users/${userHost}/home.nix {
                    inherit pkgs user home;
                  });
              };
            }
          ];
        };

      #############################################################
      # NixOS configuration
      #############################################################
      mkNixOSConfig = { system, user, host, userHost, home }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit host user home inputs; };
          modules = [
            # TODO: Add custom NixOS modules here
            (import ./hosts/nixos { inherit self system user home; })
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit user home inputs; };
                users.${user} = ({ pkgs, ... }:
                  import ./users/${userHost}/home.nix {
                    inherit pkgs user home;
                  });
              };
            }
          ];
        };

      #############################################################
      # Home-manager standalone configuration (for non-NixOS Linux)
      #############################################################
      mkHomeConfig = { system, user, host, userHost, home }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit user home inputs; };
          modules = [
            ({ pkgs, ... }:
              (import ./users/${userHost}/home.nix { inherit pkgs user home; }))
            { targets.genericLinux.enable = true; }
          ];
        };

    in {
      # Darwin configurations (macOS)
      darwinConfigurations = {
        "CemDK-MBP" = mkDarwinConfig {
          system = "x86_64-darwin";
          userHost = "cem@CemDK-MBP";
          home = "/Users/cem";
        };

        "default" = mkDarwinConfig {
          system = "aarch64-darwin";
          userHost = "kaba03@default";
          home = "/Users/kaba03";
        };
      };

      # NixOS configurations
      nixosConfigurations = {
        "desktop" = mkNixOSConfig {
          system = "x86_64-linux";
          user = "cem";
          host = "desktop";
          userHost = "cem@desktop";
          home = "/home/cem";
        };
      };

      # Home-manager standalone configurations (for non-NixOS Linux)
      homeConfigurations = {
        "cem@Cem-Ryzen" = mkHomeConfig {
          system = "x86_64-linux";
          user = "cem";
          host = "Cem-Ryzen";
          userHost = "cem@Cem-Ryzen";
          home = "/home/cem";
        };
      };
    };
}
