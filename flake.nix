{
  description =
    "Shokunix - Multi platform Nix configuration with nixos iso installer";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    # nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    # home-manager.url = "github:nix-community/home-manager/release-25.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    # TODO: manage to get this working without ugly cli errors
    # homebrew-core.url = "github:homebrew/homebrew-core";
    # homebrew-core.flake = false;
    # homebrew-cask.url = "github:homebrew/homebrew-cask";
    # homebrew-cask.flake = false;
    # homebrew-bundle.url = "github:homebrew/homebrew-bundle";
    # homebrew-bundle.flake = false;
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
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
          specialArgs = { inherit self system user host home inputs; };
          modules = [
            ./hosts/darwin/${host}/configuration.nix
            inputs.home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.${user} = {
                imports = [ ./hosts/darwin/${host}/home.nix ];
                home.username = user;
                home.homeDirectory = home;
              };
            }
            inputs.nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew.enable = true;
              nix-homebrew.enableRosetta = true;
              nix-homebrew.autoMigrate = true;
              nix-homebrew.mutableTaps = true;
              nix-homebrew.user = "${user}";
              # nix-homebrew.taps = with inputs; {
              #   "homebrew/homebrew-core" = homebrew-core;
              #   "homebrew/homebrew-cask" = homebrew-cask;
              #   "homebrew/homebrew-bundle" = homebrew-bundle;
              # };
            }

          ];
        };

      # ========================================================================
      # NixOS configuration
      # ========================================================================
      mkNixOSConfig = { system, user, host, home }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit self system user host home inputs; };
          modules = [
            ./hosts/nixos/${host}/configuration.nix
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.${user} = {
                imports = [ ./hosts/nixos/${host}/home.nix ];
                home.username = user;
                home.homeDirectory = home;
              };
            }
          ];
        };

      # ========================================================================
      # Standalone Home-manager configuration (for non-NixOS Linux)
      # ========================================================================
      mkHomeConfig = { system, user, host, home }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit self system user host home inputs; };
          modules = [
            ./hosts/linux/${host}/home.nix
            {
              home.username = user;
              home.homeDirectory = home;
              targets.genericLinux.enable = true;
            }
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

      # ========================================================================
      # CONFIG DEFINTIONS
      # ========================================================================
      # Darwin configurations (macOS)
      darwinConfigurations = {
        "CemDK-MBP" = mkDarwinConfig {
          system = "x86_64-darwin";
          user = "cem";
          host = "CemDK-MBP";
          home = "/Users/cem";
        };

        "mac-mini" = mkDarwinConfig {
          system = "aarch64-darwin";
          user = "cemdk";
          host = "mac-mini";
          home = "/Users/cemdk";
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
