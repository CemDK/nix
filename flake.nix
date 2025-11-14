{
  description =
    "Shokunix - Multi platform Nix configuration with nixos iso installer";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:nixos/nixos-hardware/master";

    # nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    # nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    # home-manager.url = "github:nix-community/home-manager/master";
    # home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ self, nix-darwin, nixos-hardware, nixpkgs, home-manager, ... }:
    let
      # ========================================================================
      # Nix-Darwin configuration
      # ========================================================================
      mkDarwinConfig = { system, user, host, home }:
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit user host home inputs; };
          modules = [
            ({ pkgs, ... }:
              import ./modules/darwin/system-configuration.nix {
                inherit pkgs self system user home;
              })
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                extraSpecialArgs = { inherit user host home inputs; };
                backupFileExtension = "backup";
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${user} = ({ pkgs, ... }:
                  import "./users/${user}@${host}/home.nix" {
                    inherit pkgs user home;
                  });
              };
            }
          ];
        };

      # ========================================================================
      # NixOS configuration
      # ========================================================================
      mkNixOSConfig = { system, user, host, home }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit user host home inputs; };
          modules = [
            (import ./hosts/nixos/${host}/configuration.nix)
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                extraSpecialArgs = { inherit user host home inputs; };
                backupFileExtension = "backup";
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${user} = ({ pkgs, ... }:
                  import ./hosts/nixos/thinkpad/home.nix {
                    inherit pkgs user host home inputs;
                  });
              };
            }
          ];
        };

      # ========================================================================
      # Standalone Home-manager configuration (for non-NixOS Linux)
      # ========================================================================
      mkHomeConfig = { system, user, host, home }:
        home-manager.lib.homeManagerConfiguration {
          inherit system;
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit user host home inputs; };
          backupFileExtension = "backup";
          modules = [
            ({ pkgs, ... }:
              (import "./hosts/linux/${host}/home.nix" {
                inherit pkgs user host home;
              }))
            { targets.genericLinux.enable = true; }
          ];
        };

      # ========================================================================
      # ISO installer configuration
      # ========================================================================
      mkIsoConfig = { system, user, host, home }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit user host home inputs; };
          modules = [
            ({ modulesPath, ... }: {
              imports = [
                (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
                "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
                ./hosts/nixos/iso/configuration.nix
              ];

              # Include target system packages in ISO for offline installation
              isoImage.storeContents = [
                self.nixosConfigurations.${host}.config.system.build.toplevel
              ];
            })
          ];
        };

    in {
      #
      # nixosConfigurations = {
      #   iso = nixpkgs.lib.nixosSystem {
      #     system = "x86_64-linux";
      #     modules = [
      #       ({ modulesPath, ... }: {
      #         imports = [
      #           (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
      #           "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
      #           ./hosts/nixos/iso/configuration.nix
      #         ];
      #
      #         # Include target system packages in ISO for offline installation
      #         isoImage.storeContents = [
      #           self.nixosConfigurations.thinkpad.config.system.build.toplevel
      #         ];
      #       })
      #     ];
      #   };
      # };

      # Darwin configurations (macOS)
      darwinConfigurations = {
        "CemDK-MBP" = mkDarwinConfig {
          system = "x86_64-darwin";
          user = "cem";
          host = "CemDK-MBP";
          home = "/Users/cem";
        };

        "work" = mkDarwinConfig {
          system = "aarch64-darwin";
          user = "kaba03";
          host = "work";
          home = "/Users/kaba03";
        };
      };

      # NixOS configurations
      nixosConfigurations = {
        "thinkpad" = mkNixOSConfig {
          system = "x86_64-linux";
          user = "cemdk";
          host = "thinkpad";
          home = "/home/cemdk";
        };
        "thinkpadISO" = mkIsoConfig {
          system = "x86_64-linux";
          user = "cemdk";
          host = "thinkpad";
          home = "/home/cemdk";
        };
        "thinclient" = mkNixOSConfig {
          system = "x86_64-linux";
          user = "cemdk";
          host = "thinclient";
          home = "/home/cemdk";
        };
      };

      # Home-manager standalone configurations (for non-NixOS Linux)
      homeConfigurations = {
        "Cem-Ryzen" = mkHomeConfig {
          system = "x86_64-linux";
          user = "cem";
          host = "Cem-Ryzen";
          home = "/home/cem";
        };
      };

    };
}
