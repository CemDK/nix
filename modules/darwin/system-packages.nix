{ pkgs, config, ... }:

{
    environment.systemPackages = with pkgs; [
        alt-tab-macos
        bat
        gh
        go
        htop
        hidden-bar
        jq
        mkalias
        neofetch
        obsidian
        opentofu
        raycast
        rectangle
        ripgrep
        rustup
        skhd
        stats
        terragrunt
        tmux
        tree-sitter
        vim
        yabai
        yazi
    ];

    system.activationScripts.applications.text = let
        env = pkgs.buildEnv {
        name = "system-applications";
        paths = config.environment.systemPackages;
        pathsToLink = "/Applications";
    };
    in
    pkgs.lib.mkForce ''
        # Set up applications.
        echo "setting up /Applications..." >&2
        rm -rf /Applications/Nix\ Apps
        mkdir -p /Applications/Nix\ Apps
        find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
        while read -r src; do
            app_name=$(basename "$src")
            echo "copying $src" >&2
            ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
        done
    '';
}
