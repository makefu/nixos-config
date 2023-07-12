{ config, lib, pkgs, buildPythonPackage, ... }:

let
  mq = "192.168.8.11";
  pkg = pkgs.ampel;
in {
  systemd.services.comic-updater = {
    startAt = "daily";
    description = "update our comics";
    after = [ "network-online.target"  ] ++ (lib.optional config.services.mosquitto.enable "mosquitto.service");
    path = with pkgs; [ wget xmlstarlet ];
    wantedBy = [ "multi-user.target"  ];
    serviceConfig = {
      # User = "hass";
      #WorkingDirectory = config.services.home-assistant.configDir;
      WorkingDirectory = "/var/lib/homeassistant-docker";
      ExecStart = pkgs.writeDash "update-comics" ''
          set -euf
          mkdir -p www/
          cd www/
          # poorly drawn lines
          pic=$(wget -O-  http://www.poorlydrawnlines.com/feed/ \
            | xml sel -t -v '/rss/channel/item/content:encoded' \
            | head -n 2 | sed -n 's/.*src="\([^"]\+\)".*/\1/p' )
          wget "$pic" -nc && cp -v "$(basename "$pic")" lines.png

          #pic=$(curl -L xkcd.com 2>/dev/null | grep imgs.xkcd.com | grep title | sed -n 's/.*src="\([^"]\+\)" .*/https:\1/p')
          # xkcd
          pic=$(wget -O- https://xkcd.com/rss.xml \
            | xml sel -t -v '/rss/channel/item/description' \
            | head -n 1 | sed -n 's/.*src="\([^"]\+\)".*/\1/p' )
          wget "$pic" -nc && cp -v "$(basename "$pic")" xkcd.png
        '';
      PrivateTmp = true;
    };
  };
}
