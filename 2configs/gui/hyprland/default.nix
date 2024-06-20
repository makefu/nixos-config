{ pkgs, config, ... }:
let
  mainUser = config.krebs.build.user.name;
in {
  imports = [
    ./kitty.nix
    ./flameshot.nix
  ];
  # programs.hyprland.enable = true;
  security.pam.services.hyprlock = {};
  # security.pam.services.swaylock = {}; 

  home-manager.users.${mainUser} = {
    home.packages = with pkgs; [
      dolphin
      wofi
    ];

    programs.hyprlock.enable = true;
    # programs.swaylock.enable = true;

    services.hypridle.enable = true;
    programs.waybar.enable = true;
    programs.waybar.systemd.enable = true;
    services.network-manager-applet.enable = true;

    home.pointerCursor = {
      gtk.enable = true;
      # x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 16;
    };


    wayland.windowManager.hyprland = {
      enable = true;
      extraConfig = builtins.readFile ./hyprland.conf;
     xwayland.enable = true;
     systemd.enable = true;

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
