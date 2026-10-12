{ pkgs, ... }:
let
  # sddm-astronaut layout (centered blurred panel, big clock) with my wallpaper
  # and the oat colors from dotfiles/waybar/style.css
  theme =
    (pkgs.sddm-astronaut.override {
      themeConfig = {
        Background = "Backgrounds/oat.jpg";
        CropBackground = "true";
        DimBackground = "0.0";

        Font = "Open Sans";
        HourFormat = "HH:mm";
        DateFormat = "dddd d MMMM";

        PartialBlur = "true";
        HaveFormBackground = "false";
        FormPosition = "center";
        RoundCorners = "20";

        BackgroundColor = "#062027";
        DimBackgroundColor = "#062027";
        FormBackgroundColor = "#062027";

        TimeTextColor = "#ffffff";
        DateTextColor = "#ffffff";
        HeaderTextColor = "#ffffff";

        LoginFieldBackgroundColor = "#062027";
        PasswordFieldBackgroundColor = "#062027";
        LoginFieldTextColor = "#ffffff";
        PasswordFieldTextColor = "#ffffff";
        UserIconColor = "#ffffff";
        PasswordIconColor = "#ffffff";
        PlaceholderTextColor = "#93a1a1";
        WarningColor = "#f78104";

        LoginButtonTextColor = "#ffffff";
        LoginButtonBackgroundColor = "#005f60";
        SystemButtonsIconsColor = "#ffffff";
        SessionButtonTextColor = "#ffffff";
        VirtualKeyboardButtonTextColor = "#ffffff";

        DropdownTextColor = "#ffffff";
        DropdownBackgroundColor = "#062027";
        DropdownSelectedBackgroundColor = "#005f60";

        HighlightTextColor = "#ffffff";
        HighlightBackgroundColor = "#005f60";
        HighlightBorderColor = "#005f60";

        HoverUserIconColor = "#f78104";
        HoverPasswordIconColor = "#f78104";
        HoverSystemButtonsIconsColor = "#f78104";
        HoverSessionButtonTextColor = "#f78104";
        HoverVirtualKeyboardButtonTextColor = "#f78104";
      };
    }).overrideAttrs
      (old: {
        installPhase = old.installPhase + ''
          dir=$out/share/sddm/themes/sddm-astronaut-theme/Backgrounds
          chmod u+w $dir
          cp ${../../../dotfiles/wallpapers/oat/autumn-season-leafs-plant-scene-generative-ai.jpg} $dir/oat.jpg
        '';
      });
in
{
  # Graphical login with a session picker (Hyprland, mango, ...).
  # Sessions come from services.displayManager.sessionPackages,
  # which programs.hyprland / programs.mangowc fill in.
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
      package = pkgs.kdePackages.sddm; # astronaut is a Qt 6 theme
      theme = "sddm-astronaut-theme";
      extraPackages = [ theme ];
      # The greeter runs under weston, which has no cursor theme by default
      settings.Theme = {
        CursorTheme = "BreezeX-RosePine-Linux";
        CursorSize = 36;
      };
    };
    defaultSession = "hyprland-uwsm";
  };

  environment.systemPackages = [
    theme
    pkgs.rose-pine-cursor # cursor theme for the greeter
  ];
}
