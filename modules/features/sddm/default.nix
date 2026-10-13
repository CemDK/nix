{ pkgs, ... }:
let
  # sddm-astronaut background (blurred center column) with my wallpaper and the
  # oat colors from dotfiles/waybar/style.css. The layout comes from LoginForm.qml.
  theme =
    (pkgs.sddm-astronaut.override {
      themeConfig = {
        Background = "Backgrounds/oat.jpg";
        CropBackground = "true";
        DimBackground = "0.0";

        Font = "DejaVu Sans";

        PartialBlur = "true";
        HaveFormBackground = "false";
        FormPosition = "center";
        RoundCorners = "20";

        BackgroundColor = "#062027";
        DimBackgroundColor = "#062027";

        # Session picker and its dropdown
        SessionButtonTextColor = "#ffffff";
        HoverSessionButtonTextColor = "#f78104";
        DropdownTextColor = "#ffffff";
        DropdownBackgroundColor = "#062027";
        DropdownSelectedBackgroundColor = "#005f60";

        # Qt palette for the whole greeter
        HighlightTextColor = "#ffffff";
        HighlightBackgroundColor = "#005f60";
        HoverSystemButtonsIconsColor = "#f78104";
      };
    }).overrideAttrs
      (old: {
        installPhase = old.installPhase + ''
          dir=$out/share/sddm/themes/sddm-astronaut-theme/Backgrounds
          chmod u+w $dir
          cp ${../../../dotfiles/wallpapers/oat/autumn-season-leafs-plant-scene-generative-ai.jpg} $dir/oat.jpg

          # Same layout as the hyprlock lock screen
          components=$out/share/sddm/themes/sddm-astronaut-theme/Components
          chmod u+w $components
          install -m644 ${./LoginForm.qml} $components/LoginForm.qml
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
    defaultSession = "mango";
  };

  environment.systemPackages = [
    theme
    pkgs.rose-pine-cursor # cursor theme for the greeter
  ];
}
