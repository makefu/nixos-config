{ pkgs, lib, config, ... }:
let
  dataDir = "/media/silent/db/audiobookshelf";
  port = 3009;
  domain = "abook.euer";
in
{
  imports = [ ../cert-relay/client-euer.nix ];
  services.audiobookshelf = {
    enable = true;
    host = "::"; # for forwarding from gum, ipv6 binding
    group = "download";
    openFirewall = true;
    inherit port;
    # upstream dataDir is a name below /var/lib, not a path; the real
    # location is pinned via WorkingDirectory below
  };
  services.nginx = {
    virtualHosts."${domain}" = {
      locations."/" = {
        proxyPass = "http://localhost:${toString port}";
        proxyWebsockets = true;
      };
    };
  };
  # Relayed HTTPS for the VPN-only public name: 3modules/cert-relay.nix
  # generates abook.euer.syntax-fehler.de (onlySSL + the relayed LE wildcard
  # cert pushed from gum). *.euer.syntax-fehler.de already resolves to omo's
  # euer tunnel addresses, so this is reachable from euer members only.
  makefu.cert-relay.euer.client.nginxVhosts = {
    abook = {
      locations = {
        "/" = {
          proxyPass = "http://localhost:${toString port}";
          proxyWebsockets = true;
        };
      };
    };
  };
  # audiobookshelf resolves config/ and metadata/ relative to its cwd, so
  # WorkingDirectory alone decides where the state lives. StateDirectory= only
  # accepts names below /var/lib and would be ignored with a warning, so reset
  # it (empty value clears the list) instead of letting it point elsewhere.
  systemd.services.audiobookshelf.unitConfig.RequiresMountsFor = [ dataDir ];
  systemd.services.audiobookshelf.serviceConfig = {
    StateDirectory = lib.mkForce "";
    WorkingDirectory = lib.mkForce dataDir;
  };
  networking.firewall.allowedTCPPorts = [ port ];
  # move datadir to silent
  systemd.tmpfiles.rules = [
    "d ${dataDir} 0750 ${config.services.audiobookshelf.user} ${config.services.audiobookshelf.group} - -"
  ];
}
