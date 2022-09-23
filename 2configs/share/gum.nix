{ config, lib, pkgs, ... }:

let
  hostname = config.krebs.build.host.name;
in {
  # users.users.smbguest = {
  #   name = "smbguest";
  #   uid = config.ids.uids.smbguest;
  #   description = "smb guest user";
  #   home = "/var/empty";
  # };
  environment.systemPackages = [ pkgs.samba ];
  services.samba = {
    enable = true;
    shares = {
      cloud-proxy = {
        path = "/media/cloud";
        "read only" = "no";
        browseable = "yes";
        "guest ok" = "no";
        "valid users" = "download";
      };
    };
    extraConfig = ''
      # guest account = smbguest
      # map to guest = bad user
      # disable printing
      load printers = no
      printing = bsd
      printcap name = /dev/null
      disable spoolss = yes
    '';
  };
  networking.firewall.interfaces.retiolum.allowedTCPPorts = [ 445 ];
  networking.firewall.interfaces.wiregrill.allowedTCPPorts =  [ 445 ];
}
