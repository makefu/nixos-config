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

