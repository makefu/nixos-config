{ config, pkgs, ... }:
{
  home-manager.users.${config.krebs.build.user.name}.xdg.desktopEntries = {
    privatefox = {
      name = "Privatefox";
      exec = "${pkgs.firefox}/bin/firefox -P Privatefox";
    };
    bambu-studio-large = {
      name = "BambuStudioLarge";
      exec = toString (pkgs.writers.writeDash "bambu-studio-large" ''
        GDK_SCALE=2 XCURSOR_SIZE=32 exec ${pkgs.bambu-studio}/bin/bambu-studio
      '');
    };
  };
}
