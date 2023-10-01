{ pkgs, ... }:
{
  powerManagement.powertop.enable = true;
  services.power-profiles-daemon.enable = true;
  users.users.makefu.packages = [ pkgs.gnome.gnome-power-manager ];
}
