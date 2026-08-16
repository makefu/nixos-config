{ config, lib, pkgs, ... }:

with pkgs.stockholm.lib;
let
  hostname = config.clan.core.settings.machine.name;
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
    settings = {
      global = {
        "guest account" = "smbguest";
        "map to guest" = "bad user";
        # no printer sharing on a file server
        "load printers" = "no";
        "printing" = "bsd";
        "printcap name" = "/dev/null";
        "disable spoolss" = "yes";
      };
      media = {
        path = "/media/";
        "read only" = "no";
        browseable = "yes";
        "guest ok" = "yes";
      };
    };
  };
}
