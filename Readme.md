# Nix-Darwin System

This repository contains the configuration for my nix configurations (for nixOS, macOS, linux and wsl).
Nix home-manager is used across all systems to manage my dotfiles and user specific applications.
Nix darwin is used to manage my macOS machines using nix.

## Installation

### MacOS

1. **Install Nix:**

    ```sh
    sh <(curl -L https://nixos.org/nix/install) 
    ```

2. **Create a custom config**

    In `flake.nix` `darwinConfigurations` add your hostname and username to the `darwinConfigurations` attribute set.
    For example, if your username is `CoolGuyUser` and your hostname is `2010-Macbook`, you would add:

    ```nix
          darwinConfigurations = {
            "CoolGuyUser@2010-macbook" = mkDarwinConfig {
              system = "x86_64-darwin"; # or "aarch64-darwin" for M1/M2/M3/M4 Macs
              user = "CoolGuyUser";
              host = "2010-macbook";
              userHost = "CoolGuyUser@2010-macbook";
              home = "/Users/CoolGuyUser";
            };
            # ... other configurations
          };
    ```

    Create a new folder/file /users/CoolGuyUser/home.nix a minimal config looks like this:

    ```nix
    { pkgs, user, home, ... }:

    {
      # Import modules that you want to use
      # default.nix is my own bespoke custom made artisinal handcrafted setup
      # so beware that it already contains my configuration for zsh, tmux, zoxide, etc.
      imports = [
        ../../modules/home-manager/default.nix
      ];

      home = {
        username = user;
        homeDirectory = home;
      };

      # You can manage dotfiles here 
      home.file = { };

      # Add packages that are specific to this user here
      home.packages = with pkgs;
        [
          neovim
          go
        ];
    }
    ```

3. **Run Nix-Darwin Rebuild:**

    Then run the following commands to install Nix and Nix-Darwin:

    ```sh
    cd ~/.config && git clone https://github.com/CemDK/nix.git && cd nix
    nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake .#$(whoami)@$(hostname -s)
    ```

    After this, if you include my zsh config, you can run `nixup`, `nixswitch` and `nixclean`
