{ config, lib, pkgs, ... }:

with config.krebs.lib;
{
  networking.firewall.allowedTCPPorts = [ 25 ];

  krebs.exim-retiolum.enable = true;
  environment.systemPackages = with pkgs; [
    msmtp
  ];
}
