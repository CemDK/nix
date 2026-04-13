# Laptop-specific power management
{ ... }:
{
  services = {
    auto-cpufreq = {
      enable = true;
      settings = {
        charger = {
          governor = "performance";
          turbo = "auto";
        };
        battery = {
          governor = "powersave";
          turbo = "auto";
        };
      };
    };
    tlp.enable = true;
    power-profiles-daemon.enable = false;
  };
}
