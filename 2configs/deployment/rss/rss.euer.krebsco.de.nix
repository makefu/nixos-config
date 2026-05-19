{ pkgs, lib, config, ... }:
let
  fqdn = "rss.euer.krebsco.de";
  ratt-path = "/var/lib/ratt/";
in {
    systemd.tmpfiles.rules = ["d ${ratt-path} 0750 nginx nginx - -" ];
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

        ];
    };
  #services.tt-rss = {
  #  enable = true;
  #  virtualHost = fqdn;
  #  selfUrlPath = "https://${fqdn}";
  #};

  sops.secrets.rss-password.owner = "freshrss";
  services.nginx.virtualHosts."${fqdn}" = {
    enableACME = true;
    forceSSL = true;
    locations."/ratt/" = {
      alias = ratt-path;
      extraConfig = "autoindex on;";
    };
  };
}

