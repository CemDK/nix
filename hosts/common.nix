{ lib, pkgs, options, ... }:
{
  # ============================================================================
  # NIX CONFIGURATION
  # ============================================================================
  # home-manager requires nix.package when nix.settings is used
  nix.package = lib.mkIf (options.nix ? package) pkgs.nix;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    warn-dirty = false;
  };

  nix.gc = {
    automatic = lib.mkDefault true;
    options = "--delete-older-than 30d";
  } // lib.optionalAttrs (!pkgs.stdenv.isDarwin) {
    dates = "weekly";
  };

  nixpkgs.config.allowUnfree = true;
}
