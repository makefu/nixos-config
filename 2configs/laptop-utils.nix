{ pkgs, ... }:

# tools i use when actually working with the host.
# package version will now be maintained by nix-rebuild
#
# essentially `nix-env -q` of the main user
# TODO: split gui and non-gui
{
  krebs.per-user.makefu.packages = with pkgs; [
    # core
    at_spi2_core
    acpi
    bc
    exif
    file
    ntfs3g
    pv
    proot
    sshpass
    unzip
    unrar
    usbutils
    zip

    # dev
    python35Packages.virtualenv


    # gui
    chromium
    clipit
    feh
    firefox
    keepassx
    pcmanfm
    skype
    mirage
    tightvnc
    gnome3.dconf
    vlc
    virtmanager
    wireshark
    xdotool

    # sectools
    aria2
    binwalk
    dnsmasq
    iodine
    mtr
    nmap


    # stuff
    cac-api
    cac-panel
    krebspaste
    ledger
    pass
  ];
}
