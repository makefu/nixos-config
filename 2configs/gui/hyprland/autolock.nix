{config, ... }:
let
  mainUser = config.krebs.build.user.name;
in {
  home-manager.users.${mainUser}.services.hypridle = {
      enable = true;
      settings = {
        general = {
          ignore_dbus_inhibit = false;
          # before_sleep_cmd = "hyprlock";
          after_sleep_cmd = "hyprctl dispatch dpms on";
          # what to do when `loginctl lock-session` sends dbus lock event
          lock_cmd = "hyprlock";
        };

        listener = [
          #{
          #  timeout = 600;
          #  #on-timeout = "hyprlock";
          #}
          #{
          #  timeout = 630;
          #  #on-timeout = "hyprctl dispatch dpms off";
          #  #on-resume = "hyprctl dispatch dpms on";
          #}
          {
            timeout = 1800;
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };
}
