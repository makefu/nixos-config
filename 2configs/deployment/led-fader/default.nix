{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
let
  mq = "192.168.8.11";
in {
  systemd.services.led-fader  = {
    description = "Send led change to message queue";
    environment = {
      NIX_PATH = "/var/src";
    };
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [
      nix # nix-shell
      mosquitto #mosquitto_pub
      bash # nix-shell
    ];
    serviceConfig = {
      # User = "nobody"; # need a user with permissions to run nix-shell
      ExecStart = pkgs.writeDash "run-fader" ''
      ${./fade.py} --add-empty --mode chain 3 loop --skip-unchanged 0.002 0.1 \
        | mosquitto_pub -h ${mq} -p 1883 -l -t '/leds/nodemcu-switcher/set'
      '';
      PrivateTmp = true;
    };
  };
}
