{ config, lib, pkgs, ... }:

with lib;
{
  krebs.exim-retiolum.enable = true;
  environment.systemPackages = with pkgs; [
    msmtp
    mutt-kz
    notmuch
    # TODO: put this somewhere else
    offlineimap
  ];

}
