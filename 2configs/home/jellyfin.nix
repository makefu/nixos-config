{ lib, config, ... }:
let
  port = 8096;
in
{
        services.jellyfin.enable = true;
        # services.jellyfin.openFirewall = true;
        networking.firewall.interfaces.wiregrill = {
          allowedTCPPorts = [ 80 port 8920 ];
          allowedUDPPorts = [ 1900 7359 ];
        };
        state = [ "/var/lib/jellyfin" ];
        users.users.${config.services.jellyfin.user}.extraGroups = [ "download" "video" "render" ];

        systemd.services.jellyfin = {
        after = [ "media-cloud.mount" ];
        serviceConfig = rec {
          RequiresMountFor = [ "/media/cloud" ];
          SupplementaryGroups = lib.mkForce [ "video" "render" "download" ];
          UMask = lib.mkForce "0077";
      };
    };
  services.nginx.virtualHosts."jelly" = {
    serverAliases = [
      "jelly.lan" "movies.lan"
      "jelly.makefu.w"  "makefu.omo.w"
    ];

    locations."/" = {
      proxyPass = "http://localhost:${toString port}";
      proxyWebsockets = true;
    };
  };
}
