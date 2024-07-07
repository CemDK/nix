{
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, home-manager, nixpkgs }: {
    darwinConfigurations."CemDK-MBP" = nix-darwin.lib.darwinSystem {
      system = "x86_64-darwin"; # or "aarch64-darwin" if you're on Apple Silicon
      modules = [ 
        ({ pkgs, ... }: import ./darwin-configuration.nix {inherit pkgs self ;})
        home-manager.darwinModules.home-manager {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.cem = import ./users/cem/home.nix;
          };
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."CemDK-MBP".pkgs;
  };
}
