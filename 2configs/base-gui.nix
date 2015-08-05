{ config, lib, pkgs, ... }:

with lib;
{
  imports = [ ];
  services.xserver = {
    enable = true;
    layout = "us";

# use awesome, direct boot into
    displayManager.auto.enable = true;
# TODO: use config.krebs.users.makefu ... or not
    displayManager.auto.user = "makefu";

    windowManager = {
      awesome.enable = true;
      awesome.luaModules = [ pkgs.luaPackages.vicious ];
      default = "awesome";
    };

    desktopManager.xterm.enable = false;
    desktopManager.default = "none";
  };

  security.setuidPrograms = [ "slock" ];

# use pulseaudio
  environment.systemPackages = [ pkgs.slock ];
  hardware.pulseaudio = {
    enable = true;
    systemWide = true;
  };

}
