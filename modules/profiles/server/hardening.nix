# Server hardening configuration
{ pkgs, ... }:
{

  # TODO: Add proper server hardening configuration
  # this is not in use yet

  services.fail2ban = {
    enable = true;
    # Ban IP after 5 failures
    maxretry = 5;
    # Whitelist some subnets
    ignoreIP = [
      "192.168.178.0/24"
      "192.168.2.0/24"
    ];
    bantime = "24h"; # Ban IPs for one day on the first ban
    bantime-increment = {
      enable = true; # Enable increment of bantime after each violation
      formula = "ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
      multipliers = "1 2 4 8 16 32 64";
      maxtime = "168h"; # Do not ban for more than 1 week
      overalljails = true; # Calculate the bantime based on all the violations
    };
    jails = { };
    sshd = {
      enable = true;
      port = "ssh";
      logpath = "/var/log/auth.log";
      maxretry = 5;
    };
  };

  # Placeholder for now
  environment.systemPackages = with pkgs; [
    # Add hardening related packages here
    # e.g. apparmor, auditd, etc.
    apparmor-pam
  ];
}
