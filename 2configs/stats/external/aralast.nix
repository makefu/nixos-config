{ config, lib, pkgs, ... }:

let
  pkg = pkgs.stdenv.mkDerivation {
    name = "aralast-master";
    src = pkgs.fetchFromGitHub {
      owner = "makefu";
      repo = "aralast";
      rev = "a0d3aeaa109e219fb6fc57170e59020c23413718";
      sha256 = "0bi0nc51z5wk72lnjhg1gfzr5yvvsshyzq924yjbbqpqw08v7i4p";
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
    startAt = "Mon,Tue,Wed,Thu,Fri *-*-* 6,7,8,9,10,11,12,13,14,15:*:0,15,30,45";
    serviceConfig = {
      User = "nobody";
      ExecStart = "${pkg}/bin/aralast";
      PrivateTmp = true;
    };
  };
}
