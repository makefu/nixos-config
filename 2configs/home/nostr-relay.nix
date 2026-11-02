{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../cert-relay/euer.nix
    ../cert-relay/client-euer.nix
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

  # Public HTTPS: the real LE wildcard cert for *.euer.syntax-fehler.de is
  # relayed from gum over the euer tunnel (3modules/cert-relay.nix); the
  # path unit reloads nginx when the files change. onlySSL because public
  # DNS for this name is ULA-only — a forceSSL redirect port would be
  # unreachable from outside euer anyway.
  services.nginx.virtualHosts."nostr.${config.makefu.cert-relay.euer.domain}" = {
    onlySSL = true;
    sslCertificate = "/var/lib/cert-relay/${config.makefu.cert-relay.euer.domain}/fullchain.pem";
    sslCertificateKey = "/var/lib/cert-relay/${config.makefu.cert-relay.euer.domain}/key.pem";
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.strfry.settings.relay.port}";
      proxyWebsockets = true;
    };
  };

  # nginx must start before the first push lands: self-signed placeholder,
  # replaced by the relayed cert (2770 root:nginx dir is group-writable,
  # and preStart runs as the nginx service user).
  services.nginx.preStart = ''
    d=/var/lib/cert-relay/${config.makefu.cert-relay.euer.domain}
    [ -f "$d/key.pem" ] || ${pkgs.openssl}/bin/openssl req -x509 -newkey rsa:2048 -nodes \
      -keyout "$d/key.pem" -out "$d/fullchain.pem" -days 1 \
      -subj "/CN=nostr.${config.makefu.cert-relay.euer.domain}"
  '';
}
