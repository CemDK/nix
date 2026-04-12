{
  self,
  nixpkgs,
  inputs,
}:
{
  system,
  user,
  host,
  home,
}:
nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = {
    inherit
      self
      system
      user
      host
      home
      ;
    inherit inputs;
  };
  modules = [
    (
      { modulesPath, ... }:
      {
        imports = [
          (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
          "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
          ./configuration.nix
        ];

        # Include target system packages in ISO for offline installation
        isoImage.storeContents = [
          self.nixosConfigurations.${host}.config.system.build.toplevel
        ];
      }
    )
  ];
}
