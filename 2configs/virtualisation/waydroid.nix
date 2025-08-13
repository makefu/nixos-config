# https://wiki.nixos.org/wiki/Waydroid
{ pkgs, ... }:
{
  virtualisation.waydroid.enable = true;
  environment.systemPackages =  [ pkgs.waydroid-helper ];

  systemd = {
    packages = [ pkgs.waydroid-helper ];
    services.waydroid-mount.wantedBy = [ "waydroid-container.service" ];
  };

}
