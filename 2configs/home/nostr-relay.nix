{
  config,
  lib,
  ...
}:
let
  port = config.services.strfry.settings.relay.port;
  # one proxy body, reused for the plain vhost and both relayed TLS vhosts
  relayLocations = {
    "/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      proxyWebsockets = true; # nostr is websocket; nixos nginx provides $connection_upgrade
    };
  };
in
{
  imports = [
    ../cert-relay/client-euer.nix
    ../cert-relay/client-lan.nix
  ];
  services.strfry = {
    enable = true;
    settings = {
      # nginx on the same host proxies to this loopback port; no public listen
      relay = {
        bind = "127.0.0.1";
        # NIP-11 advertises the public relay name
        info.name = "nostr.euer.syntax-fehler.de";
        info.description = "Private nostr relay for the euer network";
      };
    };
  };
  # Relayed HTTPS: 3modules/cert-relay.nix generates
  # nostr.<domain> vhosts (onlySSL + the relayed LE wildcard cert) from
  # these; path units reload nginx when the cert files change.
  makefu.cert-relay.euer.client.nginxVhosts = {
    nostr = {
      locations = relayLocations;
    };
  };
  makefu.cert-relay.lan.client.nginxVhosts = {
    nostr = {
      locations = relayLocations;
    };
  };
  services.nginx = {
    enable = true;
    virtualHosts = {
      # Plain HTTP on purpose: the bot connects with ws:// (plain websocket),
      # and the name is wireguard/LAN-only — no public DNS, no ACME. euer
      # members reach it via the hosts entries in
      # 2configs/wireguard/euer/common.nix; the LAN via *.lan resolution from
      # the router. Mirrors the alert.euer/alert.lan pattern
      # (2configs/home/alerting/nginx.nix).
      "nostr.euer" = {
        serverAliases = [ "nostr.lan" ];
        locations = relayLocations;
      };
    };
  };
}
