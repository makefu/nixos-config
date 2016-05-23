{config, ... }:{
  users.users.smbguest = {
    name = "smbguest";
    uid = config.ids.uids.smbguest;
    description = "smb guest user";
    home = "/var/empty";
  };
  services.samba = {
    enable = true;
    shares = {
      share-home = {
        path = "/home/share/";
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
