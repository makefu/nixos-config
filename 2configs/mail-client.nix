{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
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
