{config, ... }:{
  services.avahi = {
    enable = true;
    interfaces = [ config.makefu.server.primary-itf ];
    publish.enable = true;
    publish.userServices = true;
  };
  networking.firewall.allowedUDPPorts = [ 137 138 ];
  networking.firewall.allowedTCPPorts = [ 139 445 ];
  users.users.smbguest = {
    name = "smbguest";
    uid = config.ids.uids.smbguest; # effectively systemUser
    description = "smb guest user";
    home = "/home/share";
    createHome = true;
    group = "smbguest";
  };
  users.groups.smbguest = {};
  services.samba = {
    enable = true;
    shares = {
      share-home = {
        path = "/home/share/";
        "read only" = "no";
        browseable = "yes";
        "guest ok" = "yes";
      };
      movies = {
        path = "/home/makefu/movies";
        "read only" = "yes";
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
