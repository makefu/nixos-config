{ pkgs, lib, ... }:

{
  users.users.makefu.packages = with pkgs;[ bat direnv ];
  home-manager.users.makefu = {
    programs.browserpass = { browsers = [ "firefox" ] ; enable = true; };
    programs.firefox.enable = true;
    programs.obs-studio.enable = true;
    xdg.enable = true;
    services.network-manager-applet.enable = true;
    services.blueman-applet.enable = true;
    services.pasystray.enable = true;
    systemd.user.services.pasystray.Service.Environment = "PATH=" + (lib.makeBinPath (with pkgs;[ pavucontrol paprefs /* pavumeter  */  /* paman */ ]) );
    programs.chromium = {
      enable = true;
      extensions = [
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
        "dbepggeogbaibhgnhhndojpepiihcmeb" # vimium
        # "liloimnbhkghhdhlamdjipkmadhpcjmn" # krebsgold
        "fpnmgdkabkmnadcjpehmlllkndpkmiak" # wayback machine
        "gcknhkkoolaabfmlnjonogaaifnjlfnp" # foxyproxy
        "abkfbakhjpmblaafnpgjppbmioombali" # memex
        "kjacjjdnoddnpbbcjilcajfhhbdhkpgk" # forest
      ];
    };

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
        ExecStart = "${pkgs.clipit}/bin/clipit";
        Restart = "on-abort";
      };
    };
  };
}
