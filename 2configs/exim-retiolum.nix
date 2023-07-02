{ config, lib, pkgs, ... }:

with pkgs.stockholm.lib;
{
  networking.firewall.allowedTCPPorts = [ 25 ];

  krebs.exim-retiolum.enable = true;
  krebs.exim-retiolum.rspamd.enable = true;
  environment.systemPackages = with pkgs; [
    msmtp
  ];
}
