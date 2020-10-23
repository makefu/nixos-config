{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
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
  users.users.download.uid = genid "download";
  services.samba = {
    enable = true;
    shares = {
      download = {
        path = "/var/download";
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
