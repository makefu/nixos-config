{ config, ... }:
{
  krebs.airdcpp = {
    enable = true;
    extraGroups = [ "download" ];
    web.port = 5600;
    web.users.makefu.password = builtins.readFile <secrets/airdcpp-makefu.pw>; # watch out for newline!
    hubs."krebshub" =
    { Nick = "makefu-${config.krebs.build.host.name}";
      Password = builtins.readFile <secrets/krebshub.pw>;
      Server = "adcs://hub.nsupdate.info:1511";
      AutoConnect = true;
    };
    dcpp = {
      shares = {
        # Incoming must be writeable!
        incoming = { path = config.makefu.dl-dir + "/finished/dcpp"; incoming = true; };
        audiobooks.path = config.makefu.dl-dir + "/finished/audiobooks";
      };
      Nick = "makefu";
      DownloadSpeed = "1000";
      UploadSpeed = "1000";
    };
  };
  networking.firewall.allowedTCPPorts =
  [ config.krebs.airdcpp.dcpp.InPort
    config.krebs.airdcpp.dcpp.TLSPort
  ];
  networking.firewall.allowedUDPPorts = [ config.krebs.airdcpp.dcpp.UDPPort ];

  services.nginx.virtualHosts."dcpp.${config.krebs.build.host.name}.r".locations."/" =
  { proxyPass = "http://localhost:${toString config.krebs.airdcpp.web.port}/";

    extraConfig = ''
      proxy_set_header   Host $host;
      proxy_set_header   X-Real-IP          $remote_addr;
      proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
      gzip_types      text/plain application/javascript;

      # Proxy websockets
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";

    '';
  };
  state = map (f: "${config.krebs.airdcpp.stateDir}/${f}")
    [ "Favorites.xml" "DCPlusPlus.xml" "WebServer.xml" "Recents.xml" "IgnoredUsers.xml" ];
}
