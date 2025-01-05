{ pkgs, config, ... }:
let
  mainUser = config.krebs.build.user.name;
in {
  imports = [
    ../base.nix
    ./kitty.nix
    ./passwords.nix
    ./autostart.nix
  ];
  # autostart 
  programs.hyprland.enable = true;

  programs.hyprland.xwayland.enable = true;
  # hyprlock and hypridle should be started by home-manager
  # programs.hyprlock.enable = true;

  # automatically enabled by programs.hyprlock
  #services.hypridle.enable = true;
  security.pam.services.hyprlock = {}; 

  environment.systemPackages = [ pkgs.brightnessctl ];

  home-manager.users.${mainUser} = {
    xdg.configFile."waybar/config.jsonc".source = ./waybar.jsonc;
    home.sessionVariables.NIXOS_OZONE_WL = "1";
    home.packages = with pkgs; [
      dolphin
      wofi
      grimblast # screenshot
    ];

    programs.hyprlock.enable = true;
    programs.hyprlock.settings = 
    {
      general = {
        disable_loading_bar = false;
        # grace = 10;
        hide_cursor = true;
        no_fade_in = false;
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }
      ];

      input-field = [
        {
          size = "200, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(202, 211, 245)";
          inner_color = "rgb(91, 96, 120)";
          outer_color = "rgb(24, 25, 38)";
          outline_thickness = 5;
          placeholder_text = ''Password...'';
          shadow_passes = 2;
        }
      ];
    };

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          ignore_dbus_inhibit = false;
          before_sleep_cmd = "hyprlock";
          after_sleep_cmd = "hyprctl dispatch dpms on";
          # what to do when `loginctl lock-session` sends dbus lock event
          lock_cmd = "hyprlock";
        };

        listener = [
          {
            timeout = 600;
            on-timeout = "hyprlock";
          }
          {
            timeout = 630;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            timeout = 1800;
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };
    # waybar
    programs.waybar.enable = true;
    programs.waybar.package = pkgs.waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
      });
    programs.waybar.systemd.enable = true;
    # network-manager applet
    services.network-manager-applet.enable = true;
    services.blueman-applet.enable = true;
    services.copyq.enable = true;

    home.pointerCursor = {
      gtk.enable = true;
      # x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 16;
    };


    wayland.windowManager.hyprland = {
      enable = true;
      # extraConfig = builtins.readFile ./hyprland.conf;
     xwayland.enable = true;
     systemd.enable = true;
     systemd.variables = ["--all"];
     settings = {
       monitor = [
         "eDP-1,1920x1080,0x0,1.0"
         ",preferred,auto,1.0"
         "desc:LG Electronics LG HDR 4K 0x00016601,preferred,auto,2"
         "desc:LG Electronics LG HDR 4K 0x0009DD88,preferred,auto,2"
        ];
        xwayland = {
          force_zero_scaling = true;
        };
        "$terminal" = "kitty";
        "$fileManager" = "pcmanfm";
        "$menu" = "wofi --show drun";
        exec-once = [
          #"nm-applet"
          # "waybar"
          #"blueman-applet"
          #"copyq --start-server"
        ];
        env = [
          "XCURSOR_SIZE,18"
          "HYPRCURSOR_SIZE,18"
        ];
        general = {                                                                          
          gaps_in = 1;
          gaps_out = 1;
          border_size = 1;
          "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          "col.inactive_border" = "rgba(595959aa)";
          resize_on_border = false;
          allow_tearing = false;
          layout = "dwindle";
        };
        decoration = {
          rounding = 0;

          # Change transparency of focused and unfocused windows
          active_opacity = 1.0;
          inactive_opacity = 1.0;

          #drop_shadow = false;
          #shadow_range = 4;
          #shadow_render_power = 3;
          #"col.shadow" = "rgba(1a1a1aee)";

          blur = {
              enabled = true;
              size = 3;
              passes = 1;
              vibrancy = 0.1696;
          };
        };
        animations = {
          enabled = true;
          bezier = "myBezier, 0.05, 0.05, 0.05, 1.05";
          animation = [
            "windows, 1, 1.1, myBezier"
            "windowsOut, 1, 1.1, default, popin 80%"
            "border, 1, 1.0, default"
            "borderangle, 1, 1, default"
            "fade, 1, 1, default"
            "workspaces, 1, 1, default"
          ];
        };
          # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
        dwindle = {
          pseudotile = true; # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
          preserve_split = true; # You probably want this
        };
        misc = { 
          force_default_wallpaper = -1;
          disable_hyprland_logo = true;
        };
        input = {
          kb_layout = "us";
          kb_variant = "altgr-intl";
          kb_model = "";
          kb_options = "";
          kb_rules = "";
          follow_mouse = 1;

          sensitivity = 0; # -1.0 - 1.0, 0 means no modification.

          touchpad = {
            natural_scroll = false;
          };
        };
        gestures = {
          workspace_swipe = true;
        };
        "$mainMod" = "SUPER";
        # just make it behave like awesomewm again
        bind = [
          "$mainMod, Return, exec, $terminal"
          "$mainMod SHIFT, C, killactive,"
          "$mainMod ,F, fullscreen,0"
          "$mainMod, M, exit,"
          "$mainMod, E, exec, $fileManager"
          "$mainMod, V, togglefloating,"
          "$mainMod, R, exec, $menu"
          "$mainMod, P, pseudo, # dwindle"
          "$mainMod, J, togglesplit, # dwindle"
          "$mainMod, L, exec, hyprlock"

          # move window to scratchpad

          "$mainMod, n, movetoworkspacesilent, special"
          "$mainMod SHIFT, N, togglespecialworkspace"

          # Move focus with mainMod + arrow keys
          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"

          # Switch workspaces with mainMod + [0-9]
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"
          "$mainMod, 0, workspace, 10"

          # Move active window to a workspace with mainMod + SHIFT + [0-9]
          "$mainMod SHIFT, 1, movetoworkspace, 1"
          "$mainMod SHIFT, 2, movetoworkspace, 2"
          "$mainMod SHIFT, 3, movetoworkspace, 3"
          "$mainMod SHIFT, 4, movetoworkspace, 4"
          "$mainMod SHIFT, 5, movetoworkspace, 5"
          "$mainMod SHIFT, 6, movetoworkspace, 6"
          "$mainMod SHIFT, 7, movetoworkspace, 7"
          "$mainMod SHIFT, 8, movetoworkspace, 8"
          "$mainMod SHIFT, 9, movetoworkspace, 9"
          "$mainMod SHIFT, 0, movetoworkspace, 10"
          # screenshot
          "$mainMod, Print, exec, grimblast --notify --cursor save area ~/shots/$(date +'%Y-%m-%d-At-%Ih%Mm%Ss').png"
          ",Print, exec, grimblast --notify --cursor  copy area"
        ];
        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];
        bindel= [
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ];
        bindl= ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        windowrulev2 = "suppressevent maximize, class:.*";
        debug = {
          disable_logs = false;
        };
      };
   };
 };
}
