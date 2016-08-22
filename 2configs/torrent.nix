{ config, lib, pkgs, ... }:

with config.krebs.lib;

let
  daemon-user = "tor";
  daemon-pw = (import <torrent-secrets/daemon-pw>);
  peer-port = 51412;
  web-port = 8112;
  daemon-port = 58846;
  dl-dir = "/var/download";
in {
  # prepare secrets
  krebs.build.source.torrent-secrets.file =
    if getEnv "dummy_secrets" == "true"
    then toString <stockholm/makefu/6tests/data/secrets>
    else "/home/makefu/secrets/torrent";

  users.users = {
    download = {
      name = "download";
      home = dl-dir;
      uid = genid "download";
      createHome = true;
      useDefaultShell = true;
      group = "download";
      openssh.authorizedKeys.keys = [ ];
    };
  };
  # todo: race condition, do this after download user has been created
  system.activationScripts."download-dir-chmod" = ''
    for i in finished torrents; do
      mkdir -p "${dl-dir}/$i"
      chown download:download "${dl-dir}/$i"
      chmod 770 "${dl-dir}/$i"
    done
  '';

  users.extraGroups = {
    download = {
      gid = genid "download";
      members = [
        config.krebs.build.user.name
        "download"
        "deluge"
      ];
    };
  };

  makefu.deluge = {
    enable = true;
    auth = "${daemon-user}:${daemon-pw}:10";
    # web.enable = true;
    cfg = {
      autoadd_enable = true;
      download_location = dl-dir + "/finished";
      torrentfiles_location = dl-dir + "/torrents"; copy_torrent_file = true;
      lsd = false;
      dht = false;
      upnp = false;
      natpmp = false;
      add_paused = false;
      allow_remote = true;
      remove_seed_at_ratio = false;
      move_completed = false;
      daemon_port = daemon-port;
      random_port = false;
      random_outgoing_ports = true;
      listen_ports = [ peer-port peer-port ];
      # performance tuning
      cache_expiry = 3600;
      stop_seed_at_ratio = false;
    };
  };

  networking.firewall.extraCommands = ''
    iptables -A INPUT -i retiolum -p tcp --dport ${toString daemon-port} -j ACCEPT
  '';

  networking.firewall.allowedTCPPorts = [ peer-port ];
  networking.firewall.allowedUDPPorts = [ peer-port ];
}
