{ config, lib, pkgs, ... }:

#usage: $ wvdial

let
  mainUser = config.krebs.build.user;
in {
  environment.systemPackages = with pkgs;[
    wvdial
  ];

  environment.shellAliases = {
    umts = "sudo wvdial netzclub";
  };

  # configure for NETZCLUB
  environment.wvdial.dialerDefaults = ''
    Phone = *99***1#
    Dial Command = ATDT
    Modem = /dev/ttyACM0
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

  users.extraUsers.${mainUser.name}.extraGroups = [ "dialout" ];
}
