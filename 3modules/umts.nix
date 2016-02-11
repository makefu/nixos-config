{ config, lib, pkgs, ... }:

with lib;

let
  # TODO: currently it is only netzclub
  umts-bin = pkgs.writeScriptBin "umts" ''
    #!/bin/sh
    set -euf
    systemctl start umts
    trap "systemctl stop umts;trap - INT TERM EXIT;exit" INT TERM EXIT
    echo nameserver 8.8.8.8 | tee -a /etc/resolv.conf
    journalctl -xfu umts
  '';

  wvdial-defaults = ''
    Phone = *99***1#
    Dial Command = ATDT
    Modem = ${cfg.modem-device}
    Baud = 460800
    Init1 = AT+CGDCONT=1,"IP","pinternet.interkom.de","",0,0
    Init2 = ATZ
    Init3 = ATQ0 V1 E1 S0=0 &C1 &D2 +FCLASS=0
    ISDN = 0
    Modem Type = Analog Modem
    Username = netzclub
    Password = netzclub
    Stupid Mode = 1
    Idle Seconds = 0'';

  cfg = config.makefu.umts;

  out = {
    options.makefu.umts = api;
    config = mkIf cfg.enable imp;
  };

  api = {
    enable = mkEnableOption "umts";

    modem-device = mkOption {
      default = "/dev/ttyUSB0";
      type = types.str;
      description = ''
        path to modem device, use <filename>/dev/serial/by-id/...</filename>
        to avoid race conditions.
      '';
    };
  };

  imp = {
    environment.shellAliases = {
      umts = "sudo ${umts-bin}/bin/umts";
    };
    environment.systemPackages = [ ];

    environment.wvdial.dialerDefaults = wvdial-defaults;

    systemd.services.umts = {
      description = "UMTS wvdial Service";
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "10s";
        ExecStart = "${pkgs.wvdial}/bin/wvdial -n";
      };
    };
  };
in out
