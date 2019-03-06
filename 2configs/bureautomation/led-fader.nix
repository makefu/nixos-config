{ config, lib, pkgs, buildPythonPackage, ... }:

let
  mq = "192.168.8.11";
  pkg = pkgs.ampel;
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
      ExecStart = "${pkg}/bin/ampel";
      Restart = "always";
      RestartSec = 10;
      PrivateTmp = true;
    };
  };
}
