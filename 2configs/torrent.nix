{ config, lib, pkgs, ... }:

with import <stockholm/lib>;

let
  daemon-user = "tor";
  basicAuth = import <torrent-secrets/auth.nix>;
  peer-port = 51412;
  web-port = 8112;
  daemon-port = 58846;
  base-dir = config.makefu.dl-dir;
in {

  users.users = {
    download = {
      name = "download";
      home = base-dir;
      uid = mkDefault (genid "download");
      createHome = true;
      useDefaultShell = true;
      group = "download";
      openssh.authorizedKeys.keys = [ ];
    };
  };

  # todo: race condition, do this after download user has been created
  system.activationScripts."download-dir-chmod" = ''
    for i in finished watch; do
      if test ! -d $i;then
        mkdir -p "${base-dir}/$i"
        chown rtorrent:download "${base-dir}/$i"
        chmod 775 "${base-dir}/$i"
      fi
    done
  '';

  users.extraGroups = {
    download = {
      gid = lib.mkDefault (genid "download");
      members = [
        config.krebs.build.user.name
        "download"
        "rtorrent"
        "nginx"
      ];
    };
    rtorrent.members = [ "download" ];
  };

  krebs.rtorrent = {
    enable = true;
    web = {
      enable = true;
      port = web-port;
      inherit basicAuth;
    };
    rutorrent.enable = true;
    enableXMLRPC = true;
    listenPort = peer-port;
    downloadDir = base-dir + "/finished";
    watchDir = base-dir + "/watch";
    # dump old torrents into watch folder to have them re-added
  };

  networking.firewall.extraCommands = ''
    iptables -A INPUT -i retiolum -p tcp --dport ${toString web-port} -j ACCEPT
  '';

  networking.firewall.allowedTCPPorts = [ peer-port ];
  networking.firewall.allowedUDPPorts = [ peer-port ];
}
