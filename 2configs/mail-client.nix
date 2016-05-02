{ config, lib, pkgs, ... }:

with config.krebs.lib;
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
