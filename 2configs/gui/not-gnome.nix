{ pkgs, ... }:
{
    # not used with gnome:
     services.network-manager-applet.enable = true;
     systemd.user.services.network-manager-applet.Service.Environment = ''XDG_DATA_DIRS=/run/current-system/sw/share:${pkgs.networkmanagerapplet}/share GDK_PIXBUF_MODULE_FILE=${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache'';
    services.blueman-applet.enable = true;
    services.pasystray.enable = true;

    services.flameshot.enable = true;
    systemd.user.services.flameshot.Service.Environment = lib.mkForce [
      "IMGUR_CREATE_URL=https://p.krebsco.de/image"
      "IMGUR_DELETE_URL=https://p.krebsco.de/image/delete/%%1"
      "PATH=${config.home-manager.users.makefu.home.profileDirectory}/bin"
    ];

    home.file.".config/Dharkael/flameshot.ini".text = ''
      [General]
      disabledTrayIcon=false
      drawColor=@Variant(\0\0\0\x43\x1\xff\xff\0\0\0\0\xff\xff\0\0)
      drawThickness=0
      filenamePattern=%F_%T_shot
    '';
    systemd.user.services.clipit = {
      Unit = {
        Description = "clipboard manager";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };

      Service = {
        Environment = ''XDG_DATA_DIRS=/run/current-system/sw/share:${pkgs.clipit}/share GDK_PIXBUF_MODULE_FILE=${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache'';
        ExecStart = "${pkgs.clipit}/bin/clipit";
        Restart = "on-abort";
      };
    };
}
