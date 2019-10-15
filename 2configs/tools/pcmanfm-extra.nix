{ pkgs, ... }:
{
  users.users.makefu.packages = with pkgs; [
    pcmanfm
    lxqt.lxqt-policykit
    shared_mime_info
    lxmenu-data
  ];
  environment.variables.GIO_EXTRA_MODULES = [ "${pkgs.gvfs}/lib/gio/modules" ];
  services.gvfs.enable = true;
}
