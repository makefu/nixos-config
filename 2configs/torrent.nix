{ config, lib, pkgs, ... }:

with import <stockholm/lib>;

let
  daemon-user = "tor";
  basicAuth = import <torrent-secrets/auth.nix>;
  peer-port = 51412;
  web-port = 8112;
  daemon-port = 58846;
  dl-dir = config.makefu.dl-dir;
in {
  # prepare secrets
  krebs.build.source.torrent-secrets.file =
    if getEnv "dummy_secrets" == "true"
    then toString <stockholm/makefu/6tests/data/secrets>
    else config.makefu.torrent-secrets ;

  users.users = {
    download = {
      name = "download";
      home = dl-dir;
      uid = mkDefault (genid "download");
      createHome = true;
      useDefaultShell = true;
      group = "download";
      openssh.authorizedKeys.keys = [ ];
    };
  };

  # todo: race condition, do this after download user has been created
  system.activationScripts."download-dir-chmod" = ''
    for i in finished watch torrents; do
      mkdir -p "${dl-dir}/$i"
      chown download:download "${dl-dir}/$i"
      chmod 770 "${dl-dir}/$i"
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
    downloadDir = dl-dir + "/finished";
    # dump old torrents into watch folder to have them re-added
    watchDir = dl-dir +"/watch";
  };

  networking.firewall.extraCommands = ''
    iptables -A INPUT -i retiolum -p tcp --dport ${toString web-port} -j ACCEPT
  '';

  networking.firewall.allowedTCPPorts = [ peer-port ];
  networking.firewall.allowedUDPPorts = [ peer-port ];
}
