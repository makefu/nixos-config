{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
let
  hostname = config.krebs.build.host.name;
  # TODO local-ip from the nets config
  local-ip = "192.168.1.11";
  # local-ip = config.krebs.build.host.nets.retiolum.ip4.addr;
in {

  # samba share /media/crypt1/share
  users.users.smbguest = {
    name = "smbguest";
    uid = config.ids.uids.smbguest;
    description = "smb guest user";
    home = "/var/empty";
  };
  services.samba = {
    enable = true;
    shares = {
      winshare = {
        path = "/media/crypt1/share";
        "read only" = "no";
        browseable = "yes";
        "guest ok" = "yes";
      };
      emu = {
        path = "/media/crypt1/emu";
        "read only" = "yes";
        browseable = "yes";
        "guest ok" = "yes";
      };
      usenet = {
        path = "/media/crypt0/usenet/dst";
        "read only" = "yes";
        browseable = "yes";
        "guest ok" = "yes";
      };
      pyload = {
        path = "/media/crypt0/pyload";
        "read only" = "yes";
        browseable = "yes";
        "guest ok" = "yes";
      };
      crypt0-rw = {
        path = "/media/crypt0/";
        "read only" = "no";
        browseable = "yes";
        "guest ok" = "no";
        "valid users" = "makefu";
      };
      crypt1-rw = {
        path = "/media/crypt1/";
        "read only" = "no";
        browseable = "yes";
        "guest ok" = "no";
        "valid users" = "makefu";
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
