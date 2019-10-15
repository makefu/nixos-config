{ pkgs, ... }:
{
  services.upower.enable = true;
  users.users.makefu.packages = [ pkgs.gnome3.gnome-power-manager ];
}

