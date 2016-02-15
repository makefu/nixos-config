{ config, lib, pkgs, ... }:

with config.krebs.lib;
{
  krebs.exim-retiolum.enable = true;
  environment.systemPackages = with pkgs; [
    msmtp
  ];

}
