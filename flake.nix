{
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, home-manager, nixpkgs }: 
  let
    mkDarwinConfig = { system, host, user, home }: 
      nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit host user home; };
        modules = [ 
          ({ pkgs, ... }: import ./darwin-configuration.nix {inherit pkgs self system user home;})
          home-manager.darwinModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {inherit user home;};
              users.${user} = ({pkgs, ...}: import ./users/${user}/home.nix {inherit pkgs user home ;});
            };
          }
        ];
      };
  in
  {
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
