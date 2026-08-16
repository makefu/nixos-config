{ config, lib, pkgs, ... }:

with lib;
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
