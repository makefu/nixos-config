# Expose the three UIs via nginx on *.euer (wireguard, see
# 2configs/wireguard/euer/common.nix) and *.lan (local DNS, out-of-band).
# No SSL / no auth: euer + lan are trusted, matching the hass/jelly vhosts.
{ ... }:
{
  services.nginx.virtualHosts."alert" = {
    serverAliases = [ "alert.euer" "alert.lan" ];
    locations."/" = {
      proxyPass = "http://127.0.0.1:9093";
      proxyWebsockets = true;
    };
  };
  services.nginx.virtualHosts."karma" = {
    serverAliases = [ "karma.euer" "karma.lan" ];
    locations."/" = {
      proxyPass = "http://127.0.0.1:9094";
      proxyWebsockets = true;
    };
  };
  services.nginx.virtualHosts."prometheus" = {
    serverAliases = [ "prometheus.euer" "prometheus.lan" ];
    locations."/" = {
      proxyPass = "http://127.0.0.1:9090";
      proxyWebsockets = true;
    };
  };
}
