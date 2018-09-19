{pkgs, ... }: {
  home-manager.users.makefu = {
    programs.browserpass = { browsers = [ "firefox" ] ; enable = true; };
    services.network-manager-applet.enable = true;
    services.blueman-applet.enable = true;
    services.pasystray.enable = true;

  systemd.user.services.network-manager-applet.Service.Environment = ''
        XDG_DATA_DIRS=/etc/profiles/per-user/makefu/share GDK_PIXBUF_MODULE_FILE=${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache
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
      Environment = ''
        XDG_DATA_DIRS=/etc/profiles/per-user/makefu/share GDK_PIXBUF_MODULE_FILE=${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache
      '';
      ExecStart = "${pkgs.clipit}/bin/clipit";
      Restart = "on-abort";
    };
  };
  };
}
