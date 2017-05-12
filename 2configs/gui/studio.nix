{ config, lib, ... }:
let
  user = config.makefu.gui.user;
in
{
  services.xserver.enable = true;
  services.xserver.displayManager.sddm = {
    enable = true;
    autoLogin.enable = true;
    autoLogin.user = user;
  };
  # services.xserver.windowMananger.default = "plasma5";
  services.xserver.desktopManager = {
    default = "plasma5";
    plasma5.enable = true;
  };

  services.xserver.layout = "us";
  services.xserver.xkbVariant = "altgr-intl";
  services.xserver.xkbOptions = "ctrl:nocaps";

}
