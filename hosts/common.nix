{
  inputs,
  lib,
  options,
  pkgs,
  ...
}:
{
  # ============================================================================
  # NIX CONFIGURATION
  # ============================================================================

  nix = {
    nixPath = [
      "nixpkgs=${inputs.nixpkgs}"
    ];
    # home-manager requires nix.package when nix.settings is used
    package = lib.mkIf (options.nix ? package) pkgs.nix;

    # SETTINGS
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
    };

    # GARBAGE COLLEcTION
    gc = {
      automatic = lib.mkDefault true;
      options = "--delete-older-than 30d";
    }
    // lib.optionalAttrs (!pkgs.stdenv.isDarwin) {
      dates = "weekly";
    };
  };

  nixpkgs.config.allowUnfree = true;

}
