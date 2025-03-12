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
      yabai -m space 2  --label terminal
      yabai -m space 3  --label code
      yabai -m space 4  --label chat
      yabai -m space 5  --label mail

      # assign apps to spaces
      yabai -m rule --add app="Firefox" space=firefox
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
}
