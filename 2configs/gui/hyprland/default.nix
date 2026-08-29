{ pkgs, lib, ... }:
let
  mainUser = "makefu";

  inherit (lib.generators) mkLuaInline;

  mainMod = "SUPER";
  terminal = "kitty";
  fileManager = "dolphin";
  menu = "noctalia-shell ipc call launcher toggle";

  # hl.bind(key, dispatcher, opts?). The dispatcher is a Lua *expression*
  # (hl.dsp.*), not a string, so it has to go through mkLuaInline; the
  # hyprlang bind/bindm/bindel/bindl prefixes are plain opts now.
  bindWith = opts: key: dispatcher: {
    _args = [ key (mkLuaInline dispatcher) ] ++ lib.optional (opts != { }) opts;
  };
  bind = bindWith { };
  bindMouse = bindWith { mouse = true; };
  bindLocked = bindWith { locked = true; };
  bindLockedRepeat = bindWith {
    locked = true;
    repeating = true;
  };

  exec = cmd: ''hl.dsp.exec_cmd("${cmd}")'';

  # workspace 10 lives on key 0, as it did with the hyprlang binds
  workspaces = lib.genList (n: {
    index = n + 1;
    key = toString (lib.mod (n + 1) 10);
  }) 10;
in {
  imports = [
    ../base.nix
    ../wayland-common
    ../wayland-common/hyprlock.nix
    ./passwords.nix
  ];
  # autostart
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
    #package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    #portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  # hyprlock and hypridle should be started by home-manager
  # programs.hyprlock.enable = true;

  # automatically enabled by programs.hyprlock
  #services.hypridle.enable = true;

  environment.systemPackages = [ pkgs.brightnessctl ];

  home-manager.users.${mainUser} = {
    # notification
    #services.swaync.enable = true;
    services.dunst.enable = true;
    programs.waybar.settings.mainBar = {
      modules-left = [
        "hyprland/workspaces"
        "hyprland/mode"
        "hyprland/scratchpad"
      ];
      modules-center = [
        "hyprland/window"
      ];
      "hyprland/workspaces" = {
        on-scroll-up = "hyprctl dispatch workspace e+1";
        on-scroll-down = "hyprctl dispatch workspace e-1";
        disable-scroll = true;
        all-outputs = true;
        warp-on-scroll = false;
        format = "{name}: {icon}";
        format-icons = {
          "1" = "";
          "2" = "";
          "3" = "";
          "4" = "";
          "5" = "";
          urgent = "";
          focused = "";
          default = "";
        };
      };
      "hyprland/mode" = {
        format = "<span style=\"italic\">{}</span>";
      };
      "hyprland/scratchpad" = {
        format = "{icon} {count}";
        show-empty = false;
        format-icons = [ "" "" ];
        tooltip = true;
        tooltip-format = "{app}: {title}";
      };
    };
    home.sessionVariables.NIXOS_OZONE_WL = "1";
    home.packages = with pkgs; [
      kdePackages.dolphin
      grimblast # screenshot
    ];


    # waybar, network-manager-applet, blueman-applet, copyq
    # are enabled via wayland-common/waybar.nix


    wayland.windowManager.hyprland = {
      enable = true;
      # hyprland.conf / hyprlang is deprecated upstream, hyprland.lua is the
      # current format. Every attribute below renders as one hl.<name>(...)
      # call, see https://wiki.hypr.land/Configuring/Start/
      configType = "lua";
      package = null; # use programs.hyprland.package
      portalPackage = null;

     xwayland.enable = true;
     # systemd.enable = true; # disabled in favour of uwsm ( https://wiki.hyprland.org/Useful-Utilities/Systemd-start/#uwsm )
     # systemd.variables = ["--all"];
     settings = {
       monitor = [
         {
           output = "eDP-1";
           mode = "1920x1080";
           position = "0x0";
           scale = 1;
         }
         {
           # catch-all for everything not listed above
           output = "";
           mode = "preferred";
           position = "auto";
           scale = 1;
         }
         {
           # monitors support much more than 1920
           output = "desc:LG Electronics LG HDR 4K 0x0009DD88";
           mode = "preferred";
           position = "auto";
           scale = 1.5;
         }
        ];

        env = [
          { _args = [ "XCURSOR_SIZE" "18" ]; }
          { _args = [ "HYPRCURSOR_SIZE" "18" ]; }
        ];

        config = {
          xwayland = {
            force_zero_scaling = true;
          };
          general = {
            gaps_in = 1;
            gaps_out = 1;
            border_size = 1;
            col = {
              active_border = {
                colors = [ "rgba(33ccffee)" "rgba(00ff99ee)" ];
                angle = 45;
              };
              inactive_border = "rgba(595959aa)";
            };
            resize_on_border = false;
            allow_tearing = false;
            layout = "dwindle";
          };
          decoration = {
            rounding = 0;

            # Change transparency of focused and unfocused windows
            active_opacity = 1.0;
            inactive_opacity = 1.0;

            blur = {
                enabled = true;
                size = 3;
                passes = 1;
                vibrancy = 0.1696;
            };
          };
          animations = {
            enabled = true;
          };
          # See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
          dwindle = {
            # pseudotile is bound to mainMod + P in the binds below
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
          debug = {
            disable_logs = false;
          };
        };

        #gesture = {
        #  fingers = 3;
        #  direction = "horizontal";
        #  action = "workspace";
        #};

        curve = {
          _args = [
            "myBezier"
            {
              type = "bezier";
              points = [ [ 0.05 0.05 ] [ 0.05 1.05 ] ];
            }
          ];
        };
        animation = [
          { leaf = "windows"; enabled = true; speed = 1.1; bezier = "myBezier"; }
          { leaf = "windowsOut"; enabled = true; speed = 1.1; bezier = "default"; style = "popin 80%"; }
          { leaf = "border"; enabled = true; speed = 1.0; bezier = "default"; }
          { leaf = "borderangle"; enabled = true; speed = 1; bezier = "default"; }
          { leaf = "fade"; enabled = true; speed = 1; bezier = "default"; }
          { leaf = "workspaces"; enabled = true; speed = 1; bezier = "default"; }
        ];

        # just make it behave like awesomewm again
        bind = [
          (bind "${mainMod} + Return" (exec terminal))
          (bind "${mainMod} + SHIFT + C" "hl.dsp.window.close()")
          (bind "${mainMod} + F" ''hl.dsp.window.fullscreen({ mode = "fullscreen" })'')
          (bind "${mainMod} + M" "hl.dsp.exit()")
          (bind "${mainMod} + E" (exec fileManager))
          (bind "${mainMod} + V" ''hl.dsp.window.float({ action = "toggle" })'')
          (bind "${mainMod} + R" (exec menu))
          (bind "${mainMod} + P" "hl.dsp.window.pseudo()") # dwindle
          # (bind "${mainMod} + J" ''hl.dsp.layout("togglesplit")'') # dwindle
          (bind "${mainMod} + L" (exec "hyprlock"))

          # move window to scratchpad
          (bind "${mainMod} + N" ''hl.dsp.window.move({ workspace = "special", follow = false })'')
          (bind "${mainMod} + SHIFT + N" "hl.dsp.workspace.toggle_special()")

          # Move focus with mainMod + arrow keys
          (bind "${mainMod} + left" ''hl.dsp.focus({ direction = "left" })'')
          (bind "${mainMod} + right" ''hl.dsp.focus({ direction = "right" })'')
          (bind "${mainMod} + up" ''hl.dsp.focus({ direction = "up" })'')
          (bind "${mainMod} + down" ''hl.dsp.focus({ direction = "down" })'')

          # screenshot
          (bind "${mainMod} + Print" (exec "${pkgs.gscreenshot}/bin/gscreenshot -s"))
          (bind "Print" (exec "grimblast --notify copy area"))

          # Move/resize windows with mainMod + LMB/RMB and dragging
          (bindMouse "${mainMod} + mouse:272" "hl.dsp.window.drag()")
          (bindMouse "${mainMod} + mouse:273" "hl.dsp.window.resize()")

          (bindLockedRepeat "XF86AudioLowerVolume" (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
          (bindLockedRepeat "XF86AudioRaiseVolume" (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"))
          (bindLockedRepeat "XF86MonBrightnessUp" (exec "${pkgs.brightnessctl}/bin/brightnessctl --class=backlight set +10%"))
          (bindLockedRepeat "XF86MonBrightnessDown" (exec "${pkgs.brightnessctl}/bin/brightnessctl --class=backlight set 10%-"))
          (bindLocked "XF86AudioMute" (exec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
        ]
        # Switch workspaces with mainMod + [0-9], move the active window there
        # with mainMod + SHIFT + [0-9]
        ++ lib.concatMap (ws: [
          (bind "${mainMod} + ${ws.key}" "hl.dsp.focus({ workspace = ${toString ws.index} })")
          (bind "${mainMod} + SHIFT + ${ws.key}" "hl.dsp.window.move({ workspace = ${toString ws.index} })")
        ]) workspaces;

        #window_rule = {
        #  match.class = ".*";
        #  suppress_event = "maximize";
        #};
      };
   };
 };
}
