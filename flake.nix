{
  description = "Shokunix - Multi platform Nix configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    stylix.url = "github:nix-community/stylix/release-26.05";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    walker.url = "github:abenz1267/walker";
    walker.inputs.nixpkgs.follows = "nixpkgs";
    nix-keylayout.url = "github:CemDK/nix-keylayout";
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
      inherit (nixpkgs) lib;

      helpers = import ./lib/helpers.nix { inherit lib; };
      inherit (helpers)
        assertHostDir
        mapHosts
        ;

      # Exposes the unstable channel as `pkgs.unstable.<pkg>`
      overlays = [
        (final: prev: {
          unstable = import inputs.nixpkgs-unstable {
            inherit (prev.stdenv.hostPlatform) system;
            config.allowUnfree = true;
          };
        })
      ];

      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      forAllSystems = lib.genAttrs supportedSystems;
      args = { inherit self inputs; };

      # ========================================================================
      # Home-manager module, shared by nix-darwin and NixOS
      # ========================================================================
      mkHmModule =
        hostDir:
        { config, ... }:
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            extraSpecialArgs = args;
            users.${config.common.user} = {
              imports = [ (hostDir + "/home.nix") ];
              home.username = config.common.user;
              home.homeDirectory = config.common.home;
            };
          };
        };

      # ========================================================================
      # Nix-Darwin configuration
      # ========================================================================
      mkDarwinConfig =
        { host, hostDir }:
        # ----------------------------------------------------------------------
        let
          brewConfig =
            { config, ... }:
            {
              nix-homebrew = {
                enable = true;
                enableRosetta = true;
                autoMigrate = true;
                mutableTaps = true;
                user = config.common.user;
              };
            };
        in
        # ----------------------------------------------------------------------
        nix-darwin.lib.darwinSystem {
          specialArgs = args;
          modules = [
            {
              nixpkgs.overlays = overlays;
              common.host = host;
            }
            (hostDir + "/configuration.nix")
            stylix.darwinModules.stylix
            inputs.home-manager.darwinModules.home-manager
            (mkHmModule hostDir)
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
        { host, hostDir }:
        # ----------------------------------------------------------------------
        nixpkgs.lib.nixosSystem {
          specialArgs = args;
          modules = [
            {
              nixpkgs.overlays = overlays;
              common.host = host;
            }
            (hostDir + "/configuration.nix")
            inputs.home-manager.nixosModules.home-manager
            (mkHmModule hostDir)
            sops-nix.nixosModules.sops
          ];
        };

      # ========================================================================
      # Standalone Home-manager configuration (for non-NixOS Linux)
      # ========================================================================
      mkHomeConfig =
        { system, host }:
        # ----------------------------------------------------------------------
        let
          hostDir = assertHostDir ./hosts/linux/${host};
        in
        # ----------------------------------------------------------------------
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system overlays;
            config.allowUnfree = true;
          };
          extraSpecialArgs = args;
          modules = [
            { common.host = host; }
            (hostDir + "/home.nix")
            stylix.homeModules.stylix
          ];
        };

    in
    {

      # ========================================================================
      # FORMATTER
      # ========================================================================
      # Run 'nix fmt' to format all .nix files in a project
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      # ========================================================================
      # CONFIG DEFINITIONS
      # ========================================================================
      # Darwin configurations (macOS)
      darwinConfigurations = mapHosts ./hosts/darwin mkDarwinConfig;

      # NixOS configurations
      nixosConfigurations = mapHosts ./hosts/nixos mkNixOSConfig;

      # Home-manager standalone configurations (for non-NixOS Linux)
      homeConfigurations = {
        "cem@Cem-Ryzen" = mkHomeConfig {
          system = "x86_64-linux";
          host = "Cem-Ryzen";
        };
      };
    };
}
