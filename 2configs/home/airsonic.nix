{ config, ... }:
let
  internal-ip = "192.168.111.11";
  port = 4040;
in
{
  # networking.firewall.allowedTCPPorts = [ 4040 ];
  services.airsonic = {
    enable = true;
    listenAddress = "0.0.0.0";
    inherit port;
  };
  state = [ config.services.airsonic.home ];
  services.nginx.virtualHosts."airsonic" = {
    serverAliases = [
              "airsonic.lan"
      "music"  "music.lan"
      "musik" "musik.lan"
    ];

    locations."/".proxyPass = "http://localhost:${toString port}";
    locations."/".proxyWebsockets = true;
    extraConfig = ''
      if ( $server_addr != "${internal-ip}" ) {
        return 403;
      }
    '';
  };
}
