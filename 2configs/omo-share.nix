{ config, lib, pkgs, ... }:

with config.krebs.lib;
let
  hostname = config.krebs.build.host.name;
  # TODO local-ip from the nets config
  local-ip = "192.168.1.11";
  # local-ip = head config.krebs.build.host.nets.retiolum.addrs4;
in {
  krebs.nginx = {
    enable = mkDefault true;
    servers = {
      omo-share = {
        listen = [ "${local-ip}:80" ];
        locations = singleton (nameValuePair "/" ''

          access_log off;
          # sendfile off;
          # tcp_nopush on;
          # aio on;
          sendfile on;
          sendfile_max_chunk 512k;
          directio 512;
          aio threads;
          mp4;
          autoindex on;
          root /media;
          limit_rate_after 100m;
          limit_rate 5m;
          mp4_buffer_size     4M;
          mp4_max_buffer_size 10M;
          allow all;
          access_log off;
          keepalive_timeout  65;
          keepalive_requests 200;
          reset_timedout_connection on;
          tcp_nopush on;
          gzip off;
        '');
      };
    };
  };

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
