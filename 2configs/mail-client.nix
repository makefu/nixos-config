{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
{
  environment.systemPackages = with pkgs; [
    abook
    gnupg
    imapfilter
    msmtp
    mutt
    notmuch
    offlineimap
    openssl
    w3m
  ];
}
