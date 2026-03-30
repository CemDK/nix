{ lib, ... }:
{
  options.homelab = {
    domain = lib.mkOption {
      type = lib.types.str;
      default = "cemdk.net";
      description = "Base domain for the homelab (e.g., example.com).";
    };

    email = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Email address for TLS certificate registration (e.g., via Let's Encrypt).";
    };
  };
}
