{ config, lib, ... }:
let
  ftpdir = "/home/ftp";
in {
  networking.firewall = {
    allowedTCPPorts = [ 20 21 ];
    autoLoadConntrackHelpers = true;
    connectionTrackingModules = [ "ftp" ];
    extraCommands = ''
      iptables -A PREROUTING -t raw -p tcp --dport 21 -j CT --helper ftp
    '';
  };
  systemd.services.vsftpd.preStart = lib.mkForce ''
    mkdir -p -m755 ${ftpdir}/incoming
    chown root:root ${ftpdir}
    chown ftp ${ftpdir}/incoming
  '';
  services.vsftpd = {
    enable = true;
    extraConfig = ''
      ftpd_banner=Welcome to the krebs share, use the incoming dir for new and old leaks. Join freenode#krebs
    '';
    anonymousUser = true;
    anonymousUserNoPassword = true;
    anonymousUploadEnable = true;
    anonymousMkdirEnable = true;
    writeEnable = true;
    chrootlocalUser = true;
    anonymousUserHome = ftpdir;
  };
}
