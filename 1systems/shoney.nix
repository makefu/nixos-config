{ config, pkgs, ... }:
let
  ip     = "64.137.234.215";
  alt-ip = "64.137.234.210";
  extra-ip = "64.137.234.114"; #currently unused
  gw = "64.137.234.1";
in {
  imports = [
    ../.
    ../2configs/hw/CAC.nix
    ../2configs/fs/CAC-CentOS-7-64bit.nix

  ];


  services.tinc.networks.siem.name = "sjump";

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
  networking.interfaces.enp2s1.ip4 = [
    { address = ip; prefixLength = 24; }
    { address = alt-ip; prefixLength = 24; }
  ];

  networking.defaultGateway = gw;
  networking.nameservers = [ "8.8.8.8" ];
  networking.firewall.allowedUDPPorts = [ 655 1655 ];
  networking.firewall.allowedTCPPorts = [ 655 1655 ];
}
