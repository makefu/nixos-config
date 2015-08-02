{ config, lib, pkgs, ... }:

with lib;
{
  imports = [ ];
  services.xserver.enable = true;
  services.xserver.layout = "us";

# use awesome, direct boot into
  services.xserver.displayManager.auto.enable =true;
  services.xserver.displayManager.auto.user =config.krebs.users.makefu;
  services.xserver.windowManager.awesome.enable = true;

  security.setuidPrograms = [ "slock" ];

# use pulseaudio
  environment.systemPackages = [ pkgs.slock ];
  hardware.pulseaudio = {
    enable = true;
    systemWide = true;
  };

}
