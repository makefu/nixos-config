{ pkgs, lib, ... }:
{

  imports = [
      ./base.nix
  ];
  users.users.makefu.packages = [ pkgs.chromium ];
  services.xserver = {
    layout = lib.mkForce "de";
    xkbVariant = lib.mkForce "";

    windowManager = lib.mkForce {
      awesome.enable = false;
      default = "none";
    };
    desktopManager.xfce.enable = true;

    # xrandrHeads = [ "HDMI1" "HDMI2" ];
    # prevent screen from turning off, disable dpms
    displayManager.sessionCommands = ''
      xset -display :0 s off -dpms
      xrandr --output HDMI2 --right-of HDMI1
    '';
  };
}
