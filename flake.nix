{
  description =
    "Shokunix - Multi platform Nix configuration with nixos iso installer";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    # nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    # home-manager.url = "github:nix-community/home-manager/master";
    # home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }: {

    ############################################################################
    # NixOS configuration
    ############################################################################
    nixosConfigurations = {
      # ========================================================================
      # ISO installer configuration
      # ========================================================================
      iso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({ modulesPath, ... }: {
            imports = [
              (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
              "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
              ./hosts/nixos/iso/configuration.nix
            ];

            # Include target system packages in ISO for offline installation
            isoImage.storeContents = [
              self.nixosConfigurations.thinkpad.config.system.build.toplevel
            ];
          })
        ];
      };

      # ========================================================================
      # Thinkpad
      # ========================================================================
      thinkpad = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/nixos/thinkpad/configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.cemdk = import ./hosts/nixos/thinkpad/home.nix;
              backupFileExtension = "backup";
            };
          }
        ];
      };
    };
  };
}
