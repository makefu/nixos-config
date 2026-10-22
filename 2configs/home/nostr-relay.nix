{ config, ... }:
{
  services.strfry = {
    enable = true;
    settings = {
      # nginx on the same host proxies to this loopback port; no public listen
      relay = {
        bind = "127.0.0.1";
        info.name = "nostr.euer";
        info.description = "Private nostr relay for the euer network";
      };
    };
  };
  services.nginx = {
    enable = true;
    # Plain HTTP on purpose: the bot connects with ws:// (plain websocket),
    # and the name is wireguard/LAN-only — no public DNS, no ACME. euer
    # members reach it via the hosts entries in
    # 2configs/wireguard/euer/common.nix; the LAN via *.lan resolution from
    # the router. Mirrors the alert.euer/alert.lan pattern
    # (2configs/home/alerting/nginx.nix).
    virtualHosts."nostr.euer" = {
      serverAliases = [ "nostr.lan" ];
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.strfry.settings.relay.port}";
        proxyWebsockets = true; # nostr is websocket; nixos nginx provides $connection_upgrade
      };
    };
  };
}
