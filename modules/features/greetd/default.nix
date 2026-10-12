{ pkgs, ... }:
{
  # tuigreet login, autologin into Hyprland on boot
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = ''
          ${pkgs.tuigreet}/bin/tuigreet --greeting 'SHOKUNIX' --asterisks --remember
                  --remember-user-session --time --cmd 'uwsm start hyprland-uwsm.desktop' '';
        user = "greeter";
      };
      initial_session = {
        command = "uwsm start hyprland-uwsm.desktop";
        user = "cemdk";
      };
    };
  };
}
