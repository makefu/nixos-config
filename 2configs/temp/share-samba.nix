{config, ... }:{
  users.users.smbguest = {
    name = "smbguest";
    uid = config.ids.uids.smbguest;
    group = "share";
    description = "smb guest user";
    home = "/var/empty";
  };
  users.groups.share.members = [ "makefu" ];

  networking.firewall.allowedTCPPorts = [
    139 445 # samba
  ];

  networking.firewall.allowedUDPPorts = [
    137 138
  ];
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
