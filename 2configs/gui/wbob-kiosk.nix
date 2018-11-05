{ pkgs, lib, ... }:
{

  imports = [
      ./base.nix
  ];
  users.users.makefu = {
    packages = [ pkgs.chromium ];
    extraGroups = [ "audio" "pulse" ];
  };
  services.xserver = {

    windowManager = lib.mkForce {
      awesome.enable = false;
      default = "none";
    };
    desktopManager.xfce = {
      extraSessionCommands = ''
        ${pkgs.xlibs.xset}/bin/xset -display :0 s off -dpms
        ${pkgs.xlibs.xrandr}/bin/xrandr --output HDMI2 --right-of HDMI1
      '';
      enable = true;
    };

    # xrandrHeads = [ "HDMI1" "HDMI2" ];
    # prevent screen from turning off, disable dpms
  };

  systemd.services.xset-off = {
    after = [ "display-manager.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.xlibs.xset}/bin/xset -display :0 s off -dpms";
      RemainAfterExit = "yes";
      TimeoutSec = "5s";
      RestartSec="5s";
      Restart = "on-failure";
    };
  };

}
