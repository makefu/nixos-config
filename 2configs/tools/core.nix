{ pkgs, ... }:

# tools i use when actually working with the host.
# package version will now be maintained by nix-rebuild
#
# essentially `nix-env -q` of the main user
{
  krebs.per-user.makefu.packages = with pkgs; [
    at_spi2_core
    acpi
    bc
    rsync
    exif
    file
    # fs
    ntfs3g
    dosfstools
    pv
    sshpass
    usbutils
    p7zip
    hdparm
    inetutils
    ncftp
    mutt
    tcpdump
    sysstat
    which
    weechat
    wol
    tmux
    iftop
    mkpasswd
    # storage
    smartmontools
    cifs-utils
    # net
    wget
    curl

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
