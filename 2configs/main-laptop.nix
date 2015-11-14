{ config, lib, pkgs, ... }:

# stuff for the main laptop
# this is pretty much nice-to-have and does
# not fit into base-gui

with lib;
{
  imports = [ ./base-gui.nix ];
  environment.systemPackages = with pkgs;[
    vlc
    firefox
    chromium
    keepassx
    ntfs3g
    virtmanager
    at_spi2_core # dep for virtmanager?
  ];

  services.redshift = {
    enable = true;
    latitude = "48.7";
    longitude = "9.1";
  };

}
