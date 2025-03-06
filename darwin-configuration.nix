{ pkgs, self, system, user, home, ... }:

{
  imports = [
    ./modules/darwin/system-packages.nix
    ./modules/darwin/system-defaults.nix
    ./modules/darwin/fonts.nix
  ];

  # STANDARD SETTINGS
  # services.nix-daemon.enable = true;
  nix.settings.experimental-features = "nix-command flakes";

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = system;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # User configuration
  users.users.${user}.home = "${home}";

  # Environment configuration
  environment = { shells = [ pkgs.bash pkgs.zsh ]; };

  # Make ths OS check for new settings and apply them after nixswitch/nixrebuild, instead of next login
  system.activationScripts.postActivation.text = ''
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';
}
