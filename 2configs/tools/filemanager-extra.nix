{ pkgs, ... }:
{
  users.users.makefu.packages = with pkgs; [
    # pcmanfm
    kdePackages.dolphin
    lxqt.lxqt-policykit
    shared-mime-info
    lxmenu-data
  ];
  services.gvfs.enable = true;
}
