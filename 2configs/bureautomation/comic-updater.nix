{ config, lib, pkgs, buildPythonPackage, ... }:

let
  mq = "192.168.8.11";
  pkg = pkgs.ampel;
in {
  systemd.services.comic-updater = {
    startAt = "daily";
    description = "Send led change to message queue";
    after = [ "network-online.target"  ] ++ (lib.optional config.services.mosquitto.enable "mosquitto.service");
    path = with pkgs; [ wget xmlstarlet ];
    wantedBy = [ "multi-user.target"  ];
    serviceConfig = {
      User = "hass";
      WorkingDirectory = config.services.home-assistant.configDir;
      ExecStart = pkgs.writeDash "update-poorly-drawn-lines" ''
          set -euf
          mkdir -p www/
          cd www/
          pic=$(wget -O-  http://www.poorlydrawnlines.com/feed/ \
            | xml sel -t -v '/rss/channel/item/content:encoded' \
            | head -n 2 | sed -n 's/.*src="\([^"]\+\)".*/\1/p' )
          wget "$pic" -nc && cp -v "$(basename "$pic")" lines.png
        '';
      PrivateTmp = true;
    };
  };
}
