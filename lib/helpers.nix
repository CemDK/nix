{ lib }:
{
  assertHostDir =
    dir:
    assert lib.assertMsg (builtins.pathExists dir)
      "No configuration found at ${toString dir} - check the directory name in flake.nix";
    dir;
}
