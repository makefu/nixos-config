{ pkgs, lib, ...}:
with import <stockholm/lib>;
let
  pkg = with pkgs.python3Packages;buildPythonPackage rec {
    rev = "cce2394";
    name = "arafetch-${rev}";
    propagatedBuildInputs = [
      requests
      docopt
      influxdb
      beautifulsoup4
      paho-mqtt
    ];
    src = pkgs.fetchgit {
      url = "http://cgit.euer.krebsco.de/arafetch";
      inherit rev;
      sha256 = "sha256:0zdz8sqn9n8i69rqngcg7nakmvahf1i5dwajzjpylsh1x5csv2gs";
    };
  };
  home = "/var/lib/arafetch";
in {
  users.users.arafetch = {
    uid = genid "arafetch";
    inherit home;
    createHome = true;
  };

  systemd.services.ara2mqtt = {
    startAt = "05:00:00";
    after = [ "network-online.target" ];
    path = [ pkg ];
    serviceConfig = {
      User = "arafetch";
      # Restart = "always";
      WorkingDirectory = home;
      PrivateTmp = true;
      ExecStart = pkgs.writeDash "daily-mqtt" ''
        ara2mqtt db/thales-deutschland.json --cantine thales-deutschland --host localhost
      '';
    };
  };
  systemd.services.arafetch = {
    startAt = "Mon,Wed,Fri 09:15:00";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    environment.OUTDIR = home;
    path = [ pkg  pkgs.git pkgs.wget ];
    serviceConfig = {
      User = "arafetch";
      # Restart = "always";
      WorkingDirectory = home;
      PrivateTmp = true;
      ExecStart = pkgs.writeDash "start-weekrun" ''
        weekrun || echo "weekrun failed!"
        find $OUTDIR/db -name \*.json | while read path;do
          file=''${path##*/}
          cantine=''${file%%.json}
          ara2influx $path --cantine $cantine --host wbob.r
        done
      '';
    };
  };
}
