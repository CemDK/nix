{ ... }: {
  services.yabai = {
    enable = false;
    config = {
      mouse_modifier = "alt";
      # set modifier + right-click drag to resize window (default: resize)
      mouse_action2 = "resize";
      # set modifier + left-click drag to resize window (default: move)
      mouse_action1 = "move";

      # gaps
      top_padding = 10;
      bottom_padding = 10;
      left_padding = 10;
      right_padding = 10;
      window_gap = 10;
    };
    extraConfig = ''
      # bsp, stack or float
      yabai -m config layout bsp

      yabai -m config window_placement second_child

      # Mouse settings
      # yabai -m config mouse_follows_focus on

      # Disable specific apps 
      yabai -m rule --add app="^Calculator$"         manage=off
      yabai -m rule --add app="^Raycast$"            manage=off
      yabai -m rule --add app="^Pop$"                manage=off sticky=off
      yabai -m rule --add app="^System Settings$"    manage=off
      yabai -m rule --add app="^System Information$" manage=off
      yabai -m rule --add app="^System Preferences$" manage=off
      yabai -m rule --add title="Preferences$"       manage=off
      yabai -m rule --add title="Settings$"          manage=off

      # workspace management
      yabai -m space 1  --label firefox
      yabai -m space 2  --label finder
      yabai -m space 3  --label terminal
      yabai -m space 4  --label code
      yabai -m space 5  --label chat
      yabai -m space 6  --label mail

      # assign apps to spaces
      yabai -m rule --add app="Firefox" space=firefox
      yabai -m rule --add app="Finder" space=finder
      yabai -m rule --add app="Alacritty" space=terminal
      yabai -m rule --add title="Alacritty" space=terminal
      yabai -m rule --add app="VSCode" space=code
      yabai -m rule --add app="Visual Studio Code" space=code
      yabai -m rule --add app="Slack" space=chat
      yabai -m rule --add app="Microsoft Teams" space=chat
      yabai -m rule --add app="Outlook" space=mail


      # Focus some other window in the space, if a window is destroyed
      # yabai -m signal --add event=window_destroyed action="yabai -m query --windows --window &> /dev/null || yabai -m window --focus mouse"
      # yabai -m signal --add event=application_terminated action="yabai -m query --windows --window &> /dev/null || yabai -m window --focus mouse"

      # Stop focusing pop's sticky window on space change, and focus the first window that is not pop
      # yabai -m signal --add event=space_changed \
      # action="yabai -m window --focus \$(yabai -m query --windows --space | jq '[.[] | select(.app != \"Pop\")] | .[0].id')"
      # yabai -m signal --add event=space_changed \
      # action="~/.config/yabai/focus_non_pop.sh \$YABAI_SPACE_INDEX"

      yabai -m rule --apply
    '';
  };

  services.skhd = {
    enable = false;
    skhdConfig = ''
      # -- Changing Window Focus --

      # change window focus within space
      alt - j : yabai -m window --focus south
      alt - k : yabai -m window --focus north
      alt - h : yabai -m window --focus west
      alt - l : yabai -m window --focus east

      #change focus between external displays (left and right)
      alt - s: yabai -m display --focus west
      alt - g: yabai -m display --focus east

      # -- Modifying the Layout --

      # rotate layout clockwise
      shift + alt - r : yabai -m space --rotate 270

      # flip along y-axis
      shift + alt - y : yabai -m space --mirror y-axis

      # flip along x-axis
      shift + alt - x : yabai -m space --mirror x-axis

      # toggle window float
      shift + alt - t : yabai -m window --toggle float --grid 4:4:1:1:2:2


      # -- Modifying Window Size --

      # maximize a window
      shift + alt - m : yabai -m window --toggle zoom-fullscreen

      # balance out tree of windows (resize to occupy same area)
      shift + alt - e : yabai -m space --balance

      # -- Moving Windows Around --

      # swap windows
      shift + alt - j : yabai -m window --swap south
      shift + alt - k : yabai -m window --swap north
      shift + alt - h : yabai -m window --swap west
      shift + alt - l : yabai -m window --swap east

      # move window and split
      ctrl + alt - j : yabai -m window --warp south
      ctrl + alt - k : yabai -m window --warp north
      ctrl + alt - h : yabai -m window --warp west
      ctrl + alt - l : yabai -m window --warp east

      # move window to display left and right
      shift + alt - s : yabai -m window --display west; yabai -m display --focus west;
      shift + alt - g : yabai -m window --display east; yabai -m display --focus east;


      # move window to prev and next space
      shift + alt - p : yabai -m window --space prev;
      shift + alt - n : yabai -m window --space next;

      # move window to space #
      shift + alt - 1 : yabai -m window --space 1;
      shift + alt - 2 : yabai -m window --space 2;
      shift + alt - 3 : yabai -m window --space 3;
      shift + alt - 4 : yabai -m window --space 4;
      shift + alt - 5 : yabai -m window --space 5;
      shift + alt - 6 : yabai -m window --space 6;
      shift + alt - 7 : yabai -m window --space 7;

      alt + j : yabai -m window --space 1;
      alt + k : yabai -m window --space 3;

      # -- Starting/Stopping/Restarting Yabai --

      # stop/start/restart yabai
      ctrl + alt - q : yabai --stop-service
      ctrl + alt - s : yabai --start-service
      ctrl + alt - r : yabai --restart-service
    '';
  };
}
