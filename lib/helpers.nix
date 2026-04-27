{ lib }:
{
  assertHostDir =
    dir:
    assert lib.assertMsg (builtins.pathExists dir)
      "No configuration found at ${toString dir} - check the directory name in flake.nix";
    dir;

  mapModules =
    dir: fn:
    lib.mapAttrs' (
      name: _: lib.nameValuePair (lib.removeSuffix ".nix" name) (fn (dir + "/${name}"))
    ) (lib.filterAttrs (n: _: lib.hasSuffix ".nix" n) (builtins.readDir dir));

  format = {
    header = text: "echo \$'\\n\\e[1m'${text}\$'\\e[0m'";
    red = text: "echo - \$'\\e[0;31m'${text}\$'\\e[0m'";
    green = text: "echo - \$'\\e[0;32m'${text}\$'\\e[0m'";
    yellow = text: "echo - \$'\\e[0;33m'${text}\$'\\e[0m'";
    blue = text: "echo - \$'\\e[0;34m'${text}\$'\\e[0m'";
    magenta = text: "echo - \$'\\e[0;35m'${text}\$'\\e[0m'";
    cyan = text: "echo - \$'\\e[0;36m'${text}\$'\\e[0m'";

    inline = {
      red = text: "\\e[0;31m${text}\\e[0m";
      green = text: "\\e[0;32m${text}\\e[0m";
      yellow = text: "\\e[0;33m${text}\\e[0m";
      blue = text: "\\e[0;34m${text}\\e[0m";
      magenta = text: "\\e[0;35m${text}\\e[0m";
      cyan = text: "\\e[0;36m${text}\\e[0m";
    };
  };
}
