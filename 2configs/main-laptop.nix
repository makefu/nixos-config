{ config, lib, pkgs, ... }:

# stuff for the main laptop
# this is pretty much nice-to-have and does
# not fit into base-gui
# TODO split generic desktop stuff and laptop-specifics like lidswitching

with lib;
{
  imports = [
    ./base-gui.nix
    ./fetchWallpaper.nix
    ./zsh-user.nix
  ];
  environment.systemPackages = with pkgs;[
    vlc
    firefox
    chromium
    keepassx
    ntfs3g
    at_spi2_core
    gnome3.dconf
    virtmanager
    krebspaste
  ];

  services.redshift = {
    enable = true;
    latitude = "48.7";
    longitude = "9.1";
  };

}
