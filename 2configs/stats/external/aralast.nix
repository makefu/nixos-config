{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
let
  pkg = pkgs.stdenv.mkDerivation {
    name = "aralast-master";
    src = pkgs.fetchFromGitHub {
      owner = "makefu";
      repo = "aralast";
      rev = "7121598";
      sha256 = "0vw027c698h9b69ksid5p3pji9960hd7n9xi4arrax0vfkwryb4m";
    };
    installPhase = ''
      install -m755 -D aralast.sh $out/bin/aralast
    '';
  };
in {
  systemd.services.aralast  = {
    description = "periodically fetch aramark";
    path = [
      pkgs.curl
      pkgs.gnugrep
      pkgs.gnused
    ];
    wantedBy = [ "multi-user.target" ];
    environment = {
      INFLUX_HOST = "localhost";
      INFLUX_PORT = "8086";
    };
    # every 10 seconds when the cantina is open
    startAt = "Mon,Tue,Wed,Thu,Fri *-*-* 6,7,8,9,10,11,12,13,14,15:*:0/10";
    serviceConfig = {
      User = "nobody";
      ExecStart = "${pkg}/bin/aralast";
      PrivateTmp = true;
    };
  };
}
