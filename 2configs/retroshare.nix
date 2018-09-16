{ pkgs, ... }:
let
  port = 9024;
in {
  users.users.makefu.packages = [
    pkgs.retroshare
  ];
  networking.firewall.allowedTCPPorts = [ port ];
  networking.firewall.allowedUDPPorts = [ port ];
}
