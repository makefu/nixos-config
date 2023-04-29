{ pkgs, lib, ... }:
{

  imports = [
      ./base.nix
  ];
  users.users.kiosk = {
    packages = with pkgs;[ chromium vscode spotify tartube-yt-dlp ];
    group = "kiosk";
    isNormalUser = true;
    uid = 1003;
    extraGroups = [ "wheel" "audio" "pulse" "pipewire" ];
  };
  users.groups.kiosk.gid = 989 ;
  services.xserver = {

    windowManager = lib.mkForce { awesome.enable = false; };
    displayManager.gdm.enable = true;
    displayManager.autoLogin = {
      enable = true;
      user = lib.mkForce "kiosk";
    };
    displayManager.defaultSession = "gnome";
    desktopManager.gnome.enable = true;
    displayManager.sessionCommands = ''
        ${pkgs.xorg.xset}/bin/xset -display :0 s off -dpms
        ${pkgs.xorg.xrandr}/bin/xrandr --output HDMI2 --right-of HDMI1
      '';
    # xrandrHeads = [ "HDMI1" "HDMI2" ];
    # prevent screen from turning off, disable dpms
  };


  environment.systemPackages = [
    pkgs.gnomeExtensions.appindicator pkgs.pavucontrol pkgs.jellyfin-media-player pkgs.chromium pkgs.firefox pkgs.kodi 
    pkgs.pavucontrol
];
  services.dbus.packages = with pkgs; [ gnome2.GConf gnome3.gnome-settings-daemon ];

  systemd.services.xset-off = {
    after = [ "display-manager.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.xorg.xset}/bin/xset -display :0 s off -dpms";
      RemainAfterExit = "yes";
      TimeoutSec = "5s";
      RestartSec="5s";
      Restart = "on-failure";
    };
  };
  services.pipewire.systemWide = lib.mkForce false;
  services.pipewire.config.pipewire-pulse = {
    "pulse.properties"."server.address" = [ "unix:native" "tcp:4713" ];
  };

}
