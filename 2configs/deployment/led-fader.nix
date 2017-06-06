{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
let
  mq = "192.168.8.11";

  pkg = pkgs.stdenv.mkDerivation {
    name = "ampel-master";
    src = pkgs.fetchgit {
      url = "http://cgit.euer.krebsco.de/ampel";
      rev = "07a6791de368e16cc0864d2676fd255eba522cee";
      sha256 = "1jxjapvkfglvgapy7gjbr1nra3ay418nvz70bvypcmv7wc8d4h8q";
    };
    buildInputs = [
      (pkgs.python35.withPackages (pythonPackages: with pythonPackages; [
        docopt
        paho-mqtt
      ]))
    ];
    installPhase = ''
      install -m755 -D fade.py  $out/bin/fade.py
      install -m755 -D ampel.py $out/bin/ampel
      install -m755 -D times.json $out/share/times.json
    '';
  };
in {
  systemd.services.led-fader  = {
    description = "Send led change to message queue";
    environment = {
      NIX_PATH = "/var/src";
    };
    # after = [ (lib.optional config.services.mosqitto.enable "mosquitto.service") ];
    wantedBy = [ "multi-user.target"  ];
    serviceConfig = {
      # User = "nobody"; # need a user with permissions to run nix-shell
      ExecStart = "${pkg}/bin/ampel 4 ${pkg}/share/times.json";
      PrivateTmp = true;
    };
  };
}
