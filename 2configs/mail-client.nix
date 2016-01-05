{ config, lib, pkgs, ... }:

with lib;
{
  environment.systemPackages = with pkgs; [
    msmtp
    mutt-kz
    notmuch
    offlineimap
    imapfilter
    gnupg
  ];

}
