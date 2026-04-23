# Laptop power management — only overrides that differ from TLP defaults
{ pkgs, ... }:
{
  boot.kernelParams = [
    "pcie_aspm.policy=powersupersave"
    "amdgpu.abmlevel=2"
    "iomem=relaxed" # needed for ryzenadj PCI access on kernel 6.18+
  ];

  boot.kernel.sysctl = {
    "vm.dirty_writeback_centisecs" = 6000;
    "vm.laptop_mode" = 5;
    "vm.swappiness" = 10;
  };

  services = {
    tlp = {
      enable = true;
      settings = {
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_BOOST_ON_BAT = 0;
        PLATFORM_PROFILE_ON_BAT = "low-power";
        PCIE_ASPM_ON_BAT = "powersupersave";
      };
    };

    auto-cpufreq.enable = false;
    power-profiles-daemon.enable = false;

    # Caps TDP on battery via ryzenadj, restores full power on AC
    udev.extraRules = ''
      SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="${pkgs.bash}/bin/bash -c '${pkgs.ryzenadj}/bin/ryzenadj --stapm-limit=8000 --fast-limit=10000 --slow-limit=8000 --tctl-temp=70'"
      SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="${pkgs.bash}/bin/bash -c '${pkgs.ryzenadj}/bin/ryzenadj --stapm-limit=25000 --fast-limit=35000 --slow-limit=25000 --tctl-temp=95'"
    '';
  };

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  environment.systemPackages = with pkgs; [
    ryzenadj
    powertop
    stress-ng
    bc
  ];
}
