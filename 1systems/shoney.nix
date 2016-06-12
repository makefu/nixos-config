{ config, pkgs, ... }:
let
  ip = "64.137.235.70";
  gw = "64.137.235.1";
in {
  imports = [
    ../.
    ../../tv/2configs/hw/CAC.nix
    ../../tv/2configs/fs/CAC-CentOS-7-64bit.nix

  ];

  # minimal resources
  services.nixosManual.enable = false;
  programs.man.enable = false;
  nix.gc.automatic = true;
  nix.gc.dates = "03:10";

  krebs = {
    enable = true;
    retiolum.enable = true;
    build.host = config.krebs.hosts.shoney;
  };
  networking.interfaces.enp2s1.ip4 = [ {
    address = ip;
    prefixLength = 24;
  } ];
  networking.defaultGateway = gw;
  networking.nameservers = [ "8.8.8.8" ];
}
