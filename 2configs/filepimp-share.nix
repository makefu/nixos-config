{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
let
  hostname = config.krebs.build.host.name;
in {
  users.users.smbguest = {
    name = "smbguest";
    uid = config.ids.uids.smbguest; # effectively systemUser
    description = "smb guest user";
    home = "/var/empty";
    group = "share";
  };
  users.groups.share = {};
  services.samba = {
    enable = true;
    shares = {
      media = {
        path = "/media/";
        "read only" = "no";
        browseable = "yes";
        "guest ok" = "yes";
      };
    };
    extraConfig = ''
      guest account = smbguest
      map to guest = bad user
      # disable printing
      load printers = no
      printing = bsd
      printcap name = /dev/null
      disable spoolss = yes
    '';
  };
}
