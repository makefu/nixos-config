{ pkgs, lib, config, inputs, ... }:
let
  fqdn = "rss.euer.syntax-fehler.de";
  # wildcard cert issued on gum by the cert-relay server instance
  # (2configs/cert-relay/server-euer.nix -> 3modules/cert-relay.nix)
  certName = "euer-syntax-fehler-wildcard";
  ratt-path = "/var/lib/ratt/";
  euer = config.makefu.euer-wg.peers.gum;
in {
  systemd.tmpfiles.rules = ["d ${ratt-path} 0750 nginx nginx - -" ];
  # keep FreshRSS on the patched php84 from 6hotfix/php.nix; php85 is not
  # validated against FreshRSS upstream yet.
  services.phpfpm.pools.freshrss.phpPackage = pkgs.php84;
  services.freshrss = {
    enable = true;
    defaultUser = "makefu";
    passwordFile = config.sops.secrets.rss-password.path;
    virtualHost = fqdn;
    baseUrl = "https://${fqdn}";
    extensions = [
      (pkgs.freshrss-extensions.buildFreshRssExtension {
        FreshRssExtUniqueId = "karakeep-button";
        pname = "karakeep-button";
        version = "unstable-2025-11-26";
        src = pkgs.fetchFromGitHub {
          owner = "veverkap";
          repo = "xExtension-karakeep-button";
          rev = "8ccdace7266aa94a4795a97d311a8b494d779785";
          hash = "sha256-h0XnCSoH2djxNyo363CMz7+ZeHAhaA4G3naea2M5Pw8=";
        };
      })
      inputs.freshrss-extensions.packages.${pkgs.system}.mark-duplicate-as-read
    ];
  };

  sops.secrets.rss-password.owner = "freshrss";

  # nginx reads the relayed wildcard cert (acme-owned, group-readable);
  # acme's default group is `acme`, so give nginx membership unconditionally —
  # renewal units chown the key only when they actually run lego.
  security.acme.certs.${certName}.group = lib.mkDefault "nginx";
  users.users.nginx.extraGroups = [ "acme" ];

  services.nginx.virtualHosts."${fqdn}" = {
    # VPN-only: bind to gum's euer tunnel addresses only (public internet
    # cannot route to them) and serve the relayed LE wildcard cert directly
    # — no HTTP listener, so no enableACME.
    onlySSL = true;
    useACMEHost = certName;
    listen = [
      { addr = euer.ipv4; port = 443; ssl = true; }
      { addr = "[${euer.ula}]"; port = 443; ssl = true; }
    ];
  };

  # nginx binds the euer addresses at startup; wait for the tunnel interface
  systemd.services.nginx = {
    after = [ "sys-subsystem-net-devices-euer.device" ];
    requires = [ "sys-subsystem-net-devices-euer.device" ];
  };
}
