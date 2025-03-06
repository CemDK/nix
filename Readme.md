# Nix-Darwin System

This repository contains the configuration for my Nix-Darwin system. Nix-Darwin allows you to manage macOS configurations using the Nix package manager.

## Installation

Follow these steps to bootstrap the system:

1. **Install Nix:**

    ```sh
    sh <(curl -L https://nixos.org/nix/install) 
    ```

2. **Run Nix-Darwin Rebuild:**

    ```sh
    nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake .
    ```

This will set up your Nix-Darwin environment with the specified configurations.