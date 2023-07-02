{ config, lib, pkgs, ... }:

with pkgs.stockholm.lib;
{
  environment.systemPackages = with pkgs; [
    abook
    gnupg
    imapfilter
    msmtp
    notmuch
    neomutt
    offlineimap
    openssl
    w3m
  ];

}
