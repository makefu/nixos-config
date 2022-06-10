{ pkgs, ... }:
{
  users.users.makefu.packages = with pkgs; [
    pcmanfm
    lxqt.lxqt-policykit
    shared-mime-info
    lxmenu-data
  ];
  services.gvfs.enable = true;
}
