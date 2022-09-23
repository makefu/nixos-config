{ pkgs, lib, config, ... }:
let
  fqdn = "rss.euer.krebsco.de";
  ratt-path = "/var/lib/ratt/";
  out-path = "${ratt-path}/sofa.xml";
in {
  systemd.tmpfiles.rules = ["d ${ratt-path} 0750 nginx nginx - -" ];
  systemd.services.run-ratt-sofa = {
    enable = true;
    path = with pkgs; [ ratt xmlstarlet ];
    script = builtins.readFile ./ratt-hourly.sh;
    scriptArgs = "${./sofa-urls} ${out-path}";

    preStart = "install -v -m750 ${./sofa.yml} ${ratt-path}/sofa.yml"; # ratt requires the config file in the cwd
    serviceConfig.User = "nginx";
    serviceConfig.WorkingDirectory = ratt-path;
    startAt = "00/3:30"; # every 3 hours, fetch latest
  };

  services.nginx.virtualHosts."${fqdn}" = {
    locations."=/ratt/sofa.xml" = {
      alias = out-path;
    };
  };
}

