{ pkgs, lib, ...}:
with import <stockholm/lib>;
let
  pkg = with pkgs.python3Packages;buildPythonPackage rec {
    rev = "775d0c2";
    name = "arafetch-${rev}";
    propagatedBuildInputs = [
      requests
      docopt
      influxdb
      beautifulsoup4
    ];
    src = pkgs.fetchgit {
      url = "http://cgit.euer.krebsco.de/arafetch";
      inherit rev;
      sha256 = "0z35avn7vmbd1661ca1zkc9i4lwcm03kpwgiqxddpkp1yxhl548p";
    };
  };
  home = "/var/lib/arafetch";
in {
  users.users.arafetch = {
    uid = genid "arafetch";
    inherit home;
    createHome = true;
  };

  systemd.services.arafetch = {
    startAt = "Mon,Wed,Fri 09:15:00";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    environment = {
      OUTDIR = home;
    };
    path = [ pkg  pkgs.git pkgs.wget ];
    serviceConfig = {
      User = "arafetch";
      # Restart = "always";
      WorkingDirectory = home;
      PrivateTmp = true;
      ExecStart = pkgs.writeDash "start-weekrun" ''
        set -x
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
