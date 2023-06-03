{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
let
  hostname = config.krebs.build.host.name;
  # TODO local-ip from the nets config
  internal-ip = "192.168.111.11";
  # local-ip = config.krebs.build.host.nets.retiolum.ip4.addr;
in {

  # samba share /media/crypt1/share
  systemd.services.samba-smbd.serviceConfig.RequiresMountFor = [ "/media/cryptX" ];
  users.users.smbguest = {
    name = "smbguest";
    uid = config.ids.uids.smbguest;
    description = "smb guest user";
    home = "/var/empty";
    group = "share";
  };
  users.groups.share = {};
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
      movies = {
        path = "/media/cryptX/movies";
        "read only" = "yes";
        browseable = "yes";
        "guest ok" = "yes";
      };
      audiobook = {
        path = "/media/crypt1/audiobooks";
        "read only" = "yes";
        browseable = "yes";
        "guest ok" = "yes";
      };
      crypt0 = {
        path = "/media/crypt0";
        "read only" = "yes";
        browseable = "yes";
        "guest ok" = "yes";
      };
      anime = {
        path = "/media/cryptX/anime";
        "read only" = "yes";
        browseable = "yes";
        "guest ok" = "yes";
      };
      serien = {
        path = "/media/cryptX/series";
        "read only" = "yes";
        browseable = "yes";
        "guest ok" = "yes";
      };
      youtube = {
        path = "/media/cryptX/youtube";
        "read only" = "yes";
        browseable = "yes";
        "guest ok" = "yes";
      };
      photos = {
        path = "/media/cryptX/photos";
        "read only" = "yes";
        browseable = "yes";
        "guest ok" = "yes";
      };
      crypX-games = {
        path = "/media/cryptX/games";
        "read only" = "yes";
        browseable = "yes";
        "guest ok" = "yes";
      };
      media-rw = {
        path = "/media/";
        "read only" = "no";
        browseable = "yes";
        "guest ok" = "no";
        "valid users" = "makefu";
      };
      #cloud = {
      #  path = "/media/cloud/download/finished";
      #  "read only" = "no";
      #  browseable = "yes";
      #  "guest ok" = "yes";
      #};
    };
    extraConfig = ''
      guest account = smbguest
      map to guest = bad user
      # disable printing
      load printers = no
      printing = bsd
      printcap name = /dev/null
      disable spoolss = yes
      workgroup = WORKGROUP
      server string = ${config.networking.hostName}
      netbios name = ${config.networking.hostName}
    '';
  };
}
