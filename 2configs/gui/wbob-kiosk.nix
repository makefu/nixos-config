{ pkgs, config, lib, ... }:
{

  imports = [
    ./base.nix
    ./gnome.nix
  ];

  users.users.kiosk = {
    packages = with pkgs;[ 
      chromium vscode spotify tartube-yt-dlp  yt-dlp 
      pkgs.gnomeExtensions.appindicator
      pkgs.pavucontrol
      pkgs.chromium pkgs.firefox
      pkgs.kodi
      pkgs.guake
    ];
    group = "kiosk";
    isNormalUser = true;
    uid = 1003;
    extraGroups = [ "wheel" "audio" "pulse" "pipewire" ];
  };
  users.groups.kiosk.gid = 989 ;
  services.xserver = {
    displayManager.gdm.enable = true;
    displayManager.autoLogin = {
      enable = true;
      user = lib.mkForce "kiosk";
    };
    displayManager.defaultSession = "gnome";
    desktopManager.gnome.enable = true;
    # xrandrHeads = [ "HDMI1" "HDMI2" ];
    # prevent screen from turning off, disable dpms
  };

  services.pipewire.systemWide = lib.mkForce false;
  services.pipewire.extraConfig.pipewire."91-pulse-server" = {
    "pulse.properties" = {
      "server.address" = [ "unix:native" "tcp:4713" ];
    };
  };
  # disable sleep
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
}
