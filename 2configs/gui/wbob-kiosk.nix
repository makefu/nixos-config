{ lib, ... }:
{

  imports = [
      ./base.nix
  ];
  services.xserver = {
    layout = lib.mkForce "de";

    windowManager = lib.mkForce {
      awesome.enable = false;
      default = "none";
    };
    desktopManager.xfce.enable = true;

    # xrandrHeads = [ "HDMI1" "HDMI2" ];
    # prevent screen from turning off, disable dpms
    displayManager.sessionCommands = ''
      xset s off -dpms
      xrandr --output HDMI2 --right-of HDMI1
    '';
  };
}
