{config, ... }:{
  networking.firewall.allowedUDPPorts = [ 137 138 ];
  networking.firewall.allowedTCPPorts = [ 139 445 ];
  users.users.smbguest = {
    name = "smbguest";
    uid = config.ids.uids.smbguest; #effectively systemUser
    description = "smb guest user";
    home = "/data/lanparty";
    createHome = true;
    group = "share";
  };
  users.groups.share = {};
  services.samba = {
    enable = true;
    enableNmbd = true;
    shares = {
      lanparty = {
        path = "/data/lanparty/";
        "read only" = "yes";
        browseable = "yes";
        "guest ok" = "yes";
      };
      share = {
        path = "/data/incoming";
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
