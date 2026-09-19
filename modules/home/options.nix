{ lib, ... }:
{
  options.dev.enable = lib.mkEnableOption "development tooling (LSPs, formatters, toolchains)";
}
