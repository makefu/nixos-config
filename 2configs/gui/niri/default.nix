{ pkgs, config, ... }:
let
  mainUser = config.krebs.build.user.name;
  wallpaper = "/home/makefu/pics/nixos/nixos-logo-gruvbox-wallpaper/png/gruvbox-dark-blue.png";
in {
  imports = [
    ../base.nix
    ../wayland-common
  ];

  programs.niri.enable = true;

  # swaylock for screen locking
  security.pam.services.swaylock = {};

  environment.systemPackages = [ pkgs.brightnessctl ];

  home-manager.users.${mainUser} = {
    services.dunst.enable = true;
    programs.waybar.settings.mainBar = {
      modules-left = [
        "niri/workspaces"
        "niri/window"
      ];
      modules-center = [];
      "niri/workspaces" = {
        format = "{icon}";
        format-icons = {
          "1" = "";
          "2" = "";
          "3" = "";
          "4" = "";
          "5" = "";
          urgent = "";
          focused = "";
          default = "";
        };
      };
      "niri/window" = {
        format = "{}";
        separate-outputs = true;
      };
    };
    home.sessionVariables.NIXOS_OZONE_WL = "1";
    home.packages = with pkgs; [
      kdePackages.dolphin
      wofi
      grim
      slurp
      swaybg
      swaylock
    ];


    xdg.configFile."niri/config.kdl".text = ''
      // Niri configuration — awesome-wm-like keybindings
      input {
          keyboard {
              xkb {
                  layout "us"
                  variant "altgr-intl"
              }
              numlock
          }
          touchpad {
              tap
              dwt
          }
          mouse {}
          focus-follows-mouse max-scroll-amount="0%"
      }

      output "eDP-1" {
          mode "1920x1080"
          scale 1.0
      }

      layout {
          gaps 1
          center-focused-column "never"

          preset-column-widths {
              proportion 0.33333
              proportion 0.5
              proportion 0.66667
          }

          default-column-width { proportion 0.5; }

          // minimal border, no focus ring
          focus-ring {
              off
          }

          border {
              width 1
              active-color "#33ccff"
              inactive-color "#595959"
          }
      }

      prefer-no-csd

      screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

      // spawn processes at startup
      //spawn-at-startup "waybar"
      spawn-at-startup "${pkgs.swaybg}/bin/swaybg" "-i" "${wallpaper}" "-m" "fill"
      // spawn-at-startup "${pkgs.gnome-keyring}/bin/gnome-keyring-daemon" "--start" "--components=pkcs11,secrets,ssh"
      // spawn-at-startup "${pkgs.gnome-keyring}/bin/gnome-keyring-daemon" "--start" "--components=pkcs11,secrets"

      environment {
          XCURSOR_SIZE "18"
          SSH_AUTH_SOCK "/run/user/1000/gcr/ssh"
          NIXOS_OZONE_WL "1"
      }

      hotkey-overlay {
          skip-at-startup
      }

      animations {
          // keep default animations
      }

      // Firefox PiP as floating
      window-rule {
          match app-id=r#"firefox$"# title="^Picture-in-Picture$"
          open-floating true
      }

      binds {
          // awesome-wm-like keybindings
          Mod+Return { spawn "kitty"; }
          Mod+Shift+C { close-window; }
          Mod+F { fullscreen-window; }
          Mod+M { maximize-window-to-edges; }

          Mod+V { toggle-window-floating; }
          Mod+R { spawn "${pkgs.wofi}/bin/wofi" "--show" "drun"; }
          Mod+E { spawn "${pkgs.kdePackages.dolphin}/bin/dolphin"; }
          Mod+L { spawn "${pkgs.swaylock}/bin/swaylock"; }

          // "hide" window — move to scratchpad workspace 10
          Mod+N { move-column-to-workspace 10; }
          Mod+Shift+N { focus-workspace 10; }

          // move focus
          Mod+Left  { focus-column-left; }
          Mod+Right { focus-column-right; }
          Mod+Up    { focus-window-up; }
          Mod+Down  { focus-window-down; }

          // also move via wasd (maybe this makes more sense?
          Mod+A { focus-column-left; }
          Mod+S { focus-window-or-workspace-down; }
          Mod+W { focus-window-or-workspace-up; }
          Mod+D { focus-column-right; }

          // move columns
          Mod+Ctrl+Left  { move-column-left; }
          Mod+Ctrl+Right { move-column-right; }
          Mod+Ctrl+Up    { move-window-up; }
          Mod+Ctrl+Down  { move-window-down; }

          // switch workspaces
          Mod+1 { focus-workspace 1; }
          Mod+2 { focus-workspace 2; }
          Mod+3 { focus-workspace 3; }
          Mod+4 { focus-workspace 4; }
          Mod+5 { focus-workspace 5; }
          Mod+6 { focus-workspace 6; }
          Mod+7 { focus-workspace 7; }
          Mod+8 { focus-workspace 8; }
          Mod+9 { focus-workspace 9; }
          Mod+0 { focus-workspace 10; }

          // move window to workspace
          Mod+Shift+1 { move-column-to-workspace 1; }
          Mod+Shift+2 { move-column-to-workspace 2; }
          Mod+Shift+3 { move-column-to-workspace 3; }
          Mod+Shift+4 { move-column-to-workspace 4; }
          Mod+Shift+5 { move-column-to-workspace 5; }
          Mod+Shift+6 { move-column-to-workspace 6; }
          Mod+Shift+7 { move-column-to-workspace 7; }
          Mod+Shift+8 { move-column-to-workspace 8; }
          Mod+Shift+9 { move-column-to-workspace 9; }
          Mod+Shift+0 { move-column-to-workspace 10; }

          // column sizing
          Mod+Minus { set-column-width "-10%"; }
          Mod+Equal { set-column-width "+10%"; }
          Mod+Shift+R { switch-preset-column-width; }
          Mod+C { center-column; }

          // consume/expel windows in columns
          Mod+BracketLeft  { consume-or-expel-window-left; }
          Mod+BracketRight { consume-or-expel-window-right; }

          // screenshots
          Print { screenshot; }
          Ctrl+Print { screenshot-screen; }
          Alt+Print { screenshot-window; }

          // volume
          XF86AudioLowerVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"; }
          XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1.0"; }
          XF86AudioMute        allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; }

          // brightness
          XF86MonBrightnessUp   allow-when-locked=true { spawn "${pkgs.brightnessctl}/bin/brightnessctl" "--class=backlight" "set" "+10%"; }
          XF86MonBrightnessDown allow-when-locked=true { spawn "${pkgs.brightnessctl}/bin/brightnessctl" "--class=backlight" "set" "10%-"; }

          // overview
          Mod+O repeat=false { toggle-overview; }

          // quit
          Mod+Shift+E { quit; }


          // keyboard shortcut inhibitor escape hatch
          Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }
      }
    '';
  };
}
