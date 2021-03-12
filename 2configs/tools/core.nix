{ pkgs, ... }:

# tools i use when actually working with the host.
# package version will now be maintained by nix-rebuild
#
{
  environment.systemPackages = with pkgs; [
    ( pkgs.writeScriptBin "unknow" ''#!/bin/sh
${gnused}/bin/sed -i "''${1}d" ~/.ssh/known_hosts
    '')
    acpi
    bc
    rsync
    exif
    file
    lsof
    which
    binutils
    screen
    rename # rename 's/^/hello/' *.txt

    # fs
    cifs-utils
    dosfstools
    ntfs3g
    smartmontools

    # io
    pv
    usbutils
    p7zip
    hdparm

    # net
    wget
    curl
    inetutils
    ncftp
    tcpdump
    sysstat
    wol
    iftop

    # stockholm
    git
    gnumake
    jq
    parallel
    proot
    populate

    rxvt_unicode.terminfo
    kpaste

  ];
}
