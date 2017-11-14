{ pkgs, ... }:

# tools i use when actually working with the host.
# package version will now be maintained by nix-rebuild
#
# essentially `nix-env -q` of the main user
{
  environment.systemPackages = with pkgs; [
    at_spi2_core
    acpi
    bc
    rsync
    exif
    file
    lsof
    which
    binutils

    # fs
    cifs-utils
    dosfstools
    ntfs3g
    smartmontools

    # io
    pv
    sshpass
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

    mkpasswd
    mutt
    weechat
    tmux

    # stockholm
    git
    gnumake
    jq
    parallel
    proot
    populate

    rxvt_unicode.terminfo
    krebspaste

    # TODO:
    taskwarrior
    pass
  ];
}
