{
  config,
  lib,
  ...
}:
{
  imports = [
    ../cert-relay/euer.nix
    ../cert-relay/client-euer.nix
    ../cert-relay/lan.nix
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
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.strfry.settings.relay.port}";
          proxyWebsockets = true; # nostr is websocket; nixos nginx provides $connection_upgrade
        };
      };
    }
    # Public HTTPS: the real LE wildcard certs are relayed from gum over the
    # euer tunnel (3modules/cert-relay.nix); path units reload nginx when the
    # files change. onlySSL because the euer name is ULA-only — a forceSSL
    # redirect port would be unreachable from outside euer — and the lan name
    # keeps serving plain ws:// on the vhost above for the bot.
    //
      lib.genAttrs
        [
          "nostr.${config.makefu.cert-relay.euer.domain}"
          "nostr.${config.makefu.cert-relay.lan.domain}"
        ]
        (
          name:
          let
            domain = lib.removePrefix "nostr." name;
          in
          {
            onlySSL = true;
            sslCertificate = "/var/lib/cert-relay/${domain}/fullchain.pem";
            sslCertificateKey = "/var/lib/cert-relay/${domain}/key.pem";
            locations."/" = {
              proxyPass = "http://127.0.0.1:${toString config.services.strfry.settings.relay.port}";
              proxyWebsockets = true;
            };
          }
        );
  };
}
