{ config, lib, pkgs, ... }:

# stuff for the main laptop
# this is pretty much nice-to-have and does
# not fit into base-gui
# TODO split generic desktop stuff and laptop-specifics like lidswitching

with import <stockholm/lib>;
let
  window-manager = "awesome";
  user = config.krebs.build.user.name;
in {
  imports = [
    ./gui/base.nix
    # ./gui/look-up.nix
    ./fetchWallpaper.nix
    ./zsh-user.nix
    ./tools/core.nix
    ./tools/core-gui.nix
    ./gui/automatic-diskmount.nix
  ];

  users.users.${config.krebs.build.user.name}.extraGroups = [ "dialout" ];

  security.sudo.extraConfig = "${config.krebs.power-action.user} ALL= (root) NOPASSWD: ${pkgs.systemd}/bin/systemctl suspend";

  location.latitude = 48.7;
  location.longitude = 9.1;

}
