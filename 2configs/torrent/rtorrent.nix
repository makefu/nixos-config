{ config, lib, pkgs, ... }:

let
  peer-port = 51412;
  daemon-port = 58846;
  dldir = config.makefu.dl-dir;
in {
  imports = [
    ./flood.nix
  ];
  services.rtorrent = {
    enable = true;
    #user = "download";
    port = peer-port;
    # package = pkgs.jesec-rtorrent;
    openFirewall = true;
    group = "download";
    dataPermissions = "0775";
    downloadDir = dldir;
    configText = ''
      schedule2 = watch_start, 10, 10, ((load.start, (cat, (cfg.watch), "/media/cloud/watch/*.torrent")))
      pieces.memory.max.set = 1800M
      network.xmlrpc.size_limit.set = 16M
    '';
  };
  # allow access to the socket

  #security.acme.certs."torrent.${config.krebs.build.host.name}.r".server = config.krebs.ssl.acmeURL;
}
