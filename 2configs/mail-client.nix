{ config, lib, pkgs, ... }:

with config.krebs.lib;
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
