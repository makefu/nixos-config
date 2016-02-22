{ config, lib, pkgs, ... }:

with config.krebs.lib;
{
  environment.systemPackages = with pkgs; [
    abook
    msmtp
    mutt-kz
    notmuch
    offlineimap
    imapfilter
    gnupg
  ];
}
