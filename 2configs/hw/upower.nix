{ pkgs, ... }:
{
  services.upower.enable = true;
  users.users.makefu.packages = [ pkgs.gnome-power-manager ];
}

