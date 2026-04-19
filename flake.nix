{
  description = "Shokunix - Multi platform Nix configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    stylix.url = "github:nix-community/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    nix-keylayout.url = "git+ssh://git@github.com/CemDK/nix-keylayout";
    nix-keylayout.flake = true;
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      sops-nix,
      stylix,
      ...
    }:
    let
      lib = nixpkgs.lib;
      helpers = import ./lib/helpers.nix { inherit lib; };
      inherit (helpers) assertHostDir;

      # ========================================================================
      # Nix-Darwin configuration
      # ========================================================================
      mkDarwinConfig =
        {
          system,
          user,
          host,
          home,
        }:
        # ----------------------------------------------------------------------
        let
          hostDir = assertHostDir ./hosts/darwin/${host};
          args = {
            inherit
              self
              system
              user
              host
              home
              inputs
              ;
          };
          hmModule = {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = args;
            home-manager.users.${user} = {
              imports = [ (hostDir + "/home.nix") ];
              home.username = user;
              home.homeDirectory = home;
            };
          };
          brewConfig = {
            nix-homebrew.enable = true;
            nix-homebrew.enableRosetta = true;
            nix-homebrew.autoMigrate = true;
            nix-homebrew.mutableTaps = true;
            nix-homebrew.user = "${user}";
          };
        in
        # ----------------------------------------------------------------------
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = args;
          modules = [
            (hostDir + "/configuration.nix")
            stylix.darwinModules.stylix
            inputs.home-manager.darwinModules.home-manager
            hmModule
            inputs.nix-homebrew.darwinModules.nix-homebrew
            brewConfig
            sops-nix.darwinModules.sops
            inputs.nix-keylayout.darwinModules.default
          ];
        };

      # ========================================================================
      # NixOS configuration
      # ========================================================================
      mkNixOSConfig =
        {
          system,
          user,
          host,
          home,
          isHomelab ? false,
        }:
        # ----------------------------------------------------------------------
        let
          hostDir = assertHostDir (
            if isHomelab then ./hosts/nixos/homelab/${host} else ./hosts/nixos/${host}
          );
          args = {
            inherit
              self
              system
              user
              host
              home
              inputs
              ;
          };
          hmModule = {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = args;
            home-manager.users.${user} = {
              imports = [ (hostDir + "/home.nix") ];
              home.username = user;
              home.homeDirectory = home;
            };
          };
        in
        # ----------------------------------------------------------------------
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = args;
          modules = [
            (hostDir + "/configuration.nix")
            inputs.home-manager.nixosModules.home-manager
            hmModule
            sops-nix.nixosModules.sops
          ]
          ++ lib.optionals (!isHomelab) [
            stylix.nixosModules.stylix
          ];
        };

      # ========================================================================
      # Standalone Home-manager configuration (for non-NixOS Linux)
      # ========================================================================
      mkHomeConfig =
        {
          system,
          user,
          host,
          home,
        }:
        # ----------------------------------------------------------------------
        let
          hostDir = assertHostDir ./hosts/linux/${host};
          args = {
            inherit
              self
              system
              user
              host
              home
              inputs
              ;
          };
          hmConfig = {
            home.username = user;
            home.homeDirectory = home;
            targets.genericLinux.enable = true;
          };
        in
        # ----------------------------------------------------------------------
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = args;
          modules = [
            (hostDir + "/home.nix")
            stylix.homeModules.stylix
            hmConfig
          ];
        };

    in
    {
      # ========================================================================
      # FORMATTER
      # ========================================================================
      # Run 'nix fmt' to format all .nix files in a project
      formatter = nixpkgs.lib.genAttrs [
        # "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ] (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      # ========================================================================
      # CONFIG DEFINITIONS
      # ========================================================================
      # Darwin configurations (macOS)
      darwinConfigurations = {
        "Cems-MacBook-Pro" = mkDarwinConfig {
          system = "aarch64-darwin";
          user = "cemdk";
          host = "Cems-MacBook-Pro";
          home = "/Users/cemdk";
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
        # Personal devices
        "thinkpad" = mkNixOSConfig {
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

        # Homelab
        "wyse-5070" = mkNixOSConfig {
          system = "x86_64-linux";
          user = "cemdk";
          host = "lab-phy-01";
          home = "/home/cemdk";
          isHomelab = true;
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
