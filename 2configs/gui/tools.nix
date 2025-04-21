{ config, pkgs, ... }:
{
  home-manager.users.${config.krebs.build.user.name}.xdg.desktopEntries = {
    privatefox = {
      name = "Privatefox";
      exec = "${pkgs.firefox}/bin/firefox -P Privatefox";
    };
  };
}
