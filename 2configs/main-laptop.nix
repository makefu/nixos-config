{ config, lib, pkgs, ... }:

# stuff for the main laptop
# this is pretty much nice-to-have and does
# not fit into base-gui
# TODO split generic desktop stuff and laptop-specifics like lidswitching

with config.krebs.lib;
{
  imports = [
    ./base-gui.nix
    ./fetchWallpaper.nix
    ./zsh-user.nix
    ./laptop-utils.nix
  ];

  users.users.${config.krebs.build.user.name}.extraGroups = [ "dialout" ];


  services.redshift = {
    enable = true;
    latitude = "48.7";
    longitude = "9.1";
  };

}
