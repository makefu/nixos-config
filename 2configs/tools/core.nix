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
    exif
    file
    ntfs3g
    pv
    proot
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
    curl
    wget
    wol
    tmux
    smartmontools
    iftop

    cac-api
    cac-panel
    krebspaste
    ledger
    pass
  ];
}
