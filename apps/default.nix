{ lib, nixpkgs }:
lib.genAttrs
  [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
  ]
  (
    system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      mkApp =
        {
          name,
          runtimeInputs,
          script,
          description,
        }:
        {
          type = "app";
          program = lib.getExe (
            pkgs.writeShellApplication {
              inherit name runtimeInputs;
              text = builtins.readFile script;
            }
          );
          meta.description = description;
        };
    in
    {
      new-host = mkApp {
        name = "shokunix-new-host";
        runtimeInputs = with pkgs; [ gum ];
        script = ./new-host.sh;
        description = "Scaffold a new host configuration";
      };

      new-secret = mkApp {
        name = "shokunix-new-secret";
        runtimeInputs = with pkgs; [
          gum
          sops
          age
        ];
        script = ./new-secret.sh;
        description = "Create or edit a sops-encrypted secret file";
      };

      new-key = mkApp {
        name = "shokunix-new-key";
        runtimeInputs = with pkgs; [
          gum
          openssh
          sops
          ssh-to-age
        ];
        script = ./new-key.sh;
        description = "Onboard a machine's age key for sops decryption";
      };
    }
  )
