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
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ 
          pkgs.bat
          pkgs.go
          pkgs.htop
          pkgs.gh
          pkgs.neofetch
          pkgs.tmux
          pkgs.yazi
          pkgs.obsidian
          pkgs.vscode
        ];
      environment = {
        shells = [ pkgs.bash pkgs.zsh ];
        loginShell = pkgs.zsh;
      };

      nixpkgs.config.allowUnfree = true; 
      system.defaults = {
        dock.autohide = true;
        dock.show-recents = false;
        finder.AppleShowAllExtensions = true;
        trackpad.TrackpadThreeFingerDrag = true;
        trackpad.Clicking = true;
        #trackpad.Dragging = true;
        trackpad.TrackpadThreeFingerTapGesture = 2;
        NSGlobalDomain.InitialKeyRepeat = 14;
        NSGlobalDomain.KeyRepeat = 2;
      };
     
      users.users.cem.home = "/Users/cem";

      fonts.packages = [ (pkgs.nerdfonts.override { fonts = ["Meslo"];})];

      nix.extraOptions = ''
        experimental-features = nix-command flakes
      '';

      # STANDARD SETTINGS
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;
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
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#CemDK-MBP
    darwinConfigurations."CemDK-MBP" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration 
        home-manager.darwinModules.home-manager {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.cem.imports = [ ./modules/home-manager ];
          };
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."CemDK-MBP".pkgs;
  };
}
