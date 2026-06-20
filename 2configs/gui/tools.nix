{ config, pkgs, ... }:
{
  home-manager.users.${config.krebs.build.user.name}.xdg.desktopEntries = {
    privatefox = {
      name = "Privatefox";
      exec = "${pkgs.firefox}/bin/firefox -P Privatefox";
      icon = "${pkgs.kora-icon-theme}/share/icons/kora/status/symbolic/view-private-symbolic.svg";
    };
  };
}
