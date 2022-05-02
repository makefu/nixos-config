{ pkgs, lib, config, ... }:
let
  fqdn = "rss.euer.krebsco.de";
  ratt-path = "/var/lib/ratt/";
  out-path = "${ratt-path}/all.xml";
in {
  systemd.tmpfiles.rules = ["d ${ratt-path} 0750 nginx nginx - -" ];
  systemd.services.run-ratt = {
    enable = true;
    path = with pkgs; [ "/nix/store/vhmzblnaav2lp4lwqdgm13l55qlm79mk-ratt-unstable-2022-01-11" xmlstarlet ];
    script = builtins.readFile ./ratt-hourly.sh;
    scriptArgs = "${./urls} ${out-path}";

    preStart = "install -v -m750 ${./ebk.yml} ${ratt-path}/ebk.yml"; # ratt requires the config file in the cwd
    serviceConfig.User = "nginx";
    serviceConfig.WorkingDirectory= ratt-path;
    startAt = "00/3:07"; # every 3 hours, fetch latest
  };

  services.nginx.virtualHosts."${fqdn}" = {
    locations."=/ratt/all.xml" = {
      alias = out-path;
    };
  };
}

