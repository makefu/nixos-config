{config, ... }:{
  networking.firewall.allowedUDPPorts = [ 137 138 ];
  networking.firewall.allowedTCPPorts = [ 139 445 ];
  users.users.smbguest = {
    name = "smbguest";
    uid = config.ids.uids.smbguest;  # effectively systemUser
    description = "smb guest user";
    home = "/home/share";
    createHome = true;
    group = "smbguest";
  };
  users.groups.smbguest = {};
  users.groups.mpd.members = [ "makefu" ];
  services.samba = {
    enable = true;
    enableNmbd = true;
    shares = {
      incoming = {
        path = "/data/incoming";
        "read only" = "no";
        browseable = "yes";
        "guest ok" = "yes";
      };
      data = {
        path = "/data/";
        "read only" = "yes";
        browseable = "yes";
        "guest ok" = "yes";
      };
      music-rw = {
        path = "/data/music";
        "read only" = "no";
        browseable = "yes";
        "guest ok" = "no";
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
