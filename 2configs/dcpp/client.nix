{ pkgs, ... }:
{ # ncdc
  environment.systemPackages = [ pkgs.ncdc ];
  networking.firewall = {
    allowedUDPPorts = [ 51411 ];
    allowedTCPPorts = [ 51411 ];
  };
}

