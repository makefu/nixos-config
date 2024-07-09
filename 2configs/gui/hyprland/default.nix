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
  security.pam.services.hyprlock = {};
  # security.pam.services.swaylock = {}; 

  home-manager.users.${mainUser} = {
    home.packages = with pkgs; [
      dolphin
      wofi
      hyprland
      hypridle
      hyprlock
      grimblast # screenshot
    ];

    programs.hyprlock.enable = true;
    programs.hyprlock.settings = 
      {
        general = {
          disable_loading_bar = false;
          grace = 10;
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
    # programs.swaylock.enable = true;

    services.hypridle = {
      enable = true;
      settings = {
          general = {
            after_sleep_cmd = "hyprctl dispatch dpms on";
            ignore_dbus_inhibit = false;
            lock_cmd = "hyprlock";
          };

          listener = [
            {
              timeout = 10;
              on-timeout = "hyprlock";
            }
            {
              timeout = 20;
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on";
            }
          ];
        };
      };
    programs.waybar.enable = true;
    # programs.waybar.systemd.enable = true;
    services.network-manager-applet.enable = true;

    home.pointerCursor = {
      gtk.enable = true;
      # x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 16;
    };


    wayland.windowManager.hyprland = {
      #enable = true;
      # extraConfig = builtins.readFile ./hyprland.conf;
     # xwayland.enable = true;
     # systemd.enable = true;

     # settings = {
     #   bind =
     #    [
     #      "SUPER , F, exec, firefox"
     #      "SUPER SHIFT, c, killactive"
     #    ", Print, exec, grimblast copy area"
     #  ]
     #  ++ (
     #    # workspaces
     #    # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
     #    builtins.concatLists (builtins.genList (
     #      x: let # 1..10
     #      ws = let
     #        c = (x + 1) / 10; 
     #      in
     #      builtins.toString (x + 1 - (c * 10));
     #      in [
     #        "SUPER, ${ws}, workspace, ${toString (x + 1)}"
     #        "SUPER SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
     #      ]
     #      )
     #      10)
     #  );
     #};
    };
  };
}
