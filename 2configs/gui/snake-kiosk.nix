{ pkgs, lib, ... }:
{

  imports = [
      ./base.nix
  ];
  users.users.kiosk = {
    # packages = [ pkgs.chromium pkgs.vscode ];
    group = "kiosk";
    isNormalUser = true;
    uid = 1003;
    extraGroups = [ "wheel" "audio" "pulse" "pipewire" ];
  };
  users.groups.kiosk.gid = 989 ;
  services.xserver = {
    enable = true;

    windowManager = lib.mkForce { awesome.enable = false; };
    displayManager.gdm.enable = true;
    displayManager.gdm.autoSuspend = false;
    displayManager.autoLogin = {
      enable = true;
      user = lib.mkForce "kiosk";
    };
    displayManager.defaultSession = "gnome";
    desktopManager.gnome.enable = true;
  };

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;



  environment.systemPackages = [ pkgs.gnomeExtensions.appindicator ];
  services.dbus.packages = with pkgs; [ gnome2.GConf gnome3.gnome-settings-daemon ];

  services.pipewire.systemWide = lib.mkForce false;
  services.pipewire.config.pipewire-pulse = {
    "pulse.properties"."server.address" = [ "unix:native" "tcp:4713" ];
  };

}
