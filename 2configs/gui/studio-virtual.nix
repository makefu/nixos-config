{ config, lib, ... }:
let
  user = config.makefu.gui.user;
in
{
  imports = [
    <nixpkgs/nixos/modules/services/x11/terminal-server.nix>
  ];
  services.xserver.displayManager.sddm.enable = lib.mkForce false;
  services.xserver.desktopManager = {
    default = "plasma5";
    plasma5.enable = true;
  };

  services.xserver.layout = "us";
  services.xserver.xkbVariant = "altgr-intl";
  services.xserver.xkbOptions = "ctrl:nocaps";

}
