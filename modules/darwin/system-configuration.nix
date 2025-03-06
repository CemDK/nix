{ pkgs, self, system, user, home, ... }:

{
  imports =
    [ ./system-packages.nix ./system-defaults.nix ./skhd.nix ./yabai.nix ];

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

  security.pam.services.sudo_local.touchIdAuth = true;

  # Garbage collect once a week
  nix.gc = {
    automatic = true;
    interval = {
      Weekday = 0;
      Hour = 0;
      Minute = 0;
    };
    options = "--delete-older-than 30d";
  };
}
