{ pkgs, self, ... }:

{
  imports = [
    ./modules/darwin/system-packages.nix
    ./modules/darwin/system-defaults.nix
    ./modules/darwin/fonts.nix
  ];

  # STANDARD SETTINGS
  services.nix-daemon.enable = true;
  nix.settings.experimental-features = "nix-command flakes";

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "x86_64-darwin";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # User configuration
  users.users.cem.home = "/Users/cem";

  # Environment configuration
  environment = {
    shells = [ pkgs.bash pkgs.zsh ];
    loginShell = pkgs.zsh;
  };
}
