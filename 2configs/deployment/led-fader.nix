{ config, lib, pkgs, buildPythonPackage, ... }:

let
  mq = "192.168.8.11";

  pkg = pkgs.python3Packages.buildPythonPackage {
    name = "ampel-master";

    src = pkgs.fetchgit {
      url = "http://cgit.euer.krebsco.de/ampel";
      rev = "531741b";
      sha256 = "110yij53jz074zbswylbzcd8jy7z49r9fg6i3j1gk2y3vl91g81c";
    };
    propagatedBuildInputs = with pkgs.python3Packages; [
        docopt
        paho-mqtt
        requests
        pytz
        influxdb
        httplib2
        google_api_python_client
    ];
  };
in {
  systemd.services.led-fader  = {
    description = "Send led change to message queue";
    environment = {
      NIX_PATH = "/var/src";
    };
    after = [ "network-online.target"  ] ++ (lib.optional config.services.mosquitto.enable "mosquitto.service");
    wantedBy = [ "multi-user.target"  ];
    serviceConfig = {
      # User = "nobody"; # need a user with permissions to run nix-shell
      ExecStartPre = pkgs.writeDash "sleep.sh" "sleep 2";
      ExecStart = "${pkg}/bin/ampel 4";
      Restart = "always";
      RestartSec = 10;
      PrivateTmp = true;
    };
  };
}
