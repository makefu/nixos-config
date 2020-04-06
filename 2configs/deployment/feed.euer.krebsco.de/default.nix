{ config, lib, pkgs, ... }:
let
  filter-file = ./filter.yml;
  pkg = with pkgs.python3Packages;buildPythonPackage rec {
    version = "d16ce227dc68c9f60f6dd06e6835bab7cdfdf61b";
    pname = "ebk-notify";
    propagatedBuildInputs = [
      docopt
      pyyaml
      requests
      beautifulsoup4
      dateutil
      feedgen
    ];
    src = pkgs.fetchgit {
      url = "http://cgit.euer.krebsco.de/ebk-notify";
      rev = version;
      sha256 = "15dlhp17alm01fw7mzdyh2z9zwz8psrs489lxs3hgg1p5wa0kzsp";
    };
  };
  domain = "feed.euer.krebsco.de";
  path = "/var/www/feed.euer.krebsco.de";
in
{
  systemd.tmpfiles.rules = [
    "d ${path} nginx nogroup - -"
  ];
  krebs.secret.files.ebknotify = {
    path = "/etc/ebk-notify.yml";
    owner.name = "nginx";
    source-path = "${<secrets/ebk-notify.yml>}";
  };
  systemd.services.ebk-notify = {
    startAt = "*:0/10";
    serviceConfig = {
      User = "nginx"; # TODO better permission setting
      # PrivateTmp = true;
      ExecStart = "${pkg}/bin/ebk-notify --atom --outdir ${path} --config /etc/ebk-notify.yml --cache /tmp/ebk-cache.json --filter ${filter-file} --wait 30";
    };
  };
  systemd.timers.ebk-notify.timerConfig.RandomizedDelaySec = "120";
  services.nginx = {
    virtualHosts."${domain}" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        root = path;
        index = "root.atom";
      };
    };
  };
}
